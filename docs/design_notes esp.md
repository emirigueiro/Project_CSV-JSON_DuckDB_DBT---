# Design Notes

## 1. Ingesta de datos

Los archivos fuente se cargan en el esquema `raw` de `warehouse.duckdb` mediante un notebook de Python (`ingest/01_ingesta_raw.ipynb`), con full refresh. La ingesta se mantiene deliberadamente separada de la transformación: el cargador solo hace Extract + Load, y toda la limpieza, el tipado y las reglas de negocio viven en dbt.

- Los archivos CSV se cargan como `VARCHAR` (`all_varchar = true`). La inferencia de tipos sobre datos sucios puede fallar o convertir valores en silencio.
- Todas las tablas incluyen dos columnas de metadatos: `_loaded_at` (timestamp de carga) y `_source_file` (archivo de origen).
- `fx_rates.json` no es una lista plana, sino un objeto que contiene un array de respuestas de la API. El cargador guarda una fila por respuesta, manteniendo el mapa `rates` como JSON; se aplana en staging.

### Mejoras para producción

- **Órdenes y líneas de orden:** CDC basado en log si está disponible, ya que captura inserciones, modificaciones y borrados. Si no, una extracción incremental diaria de filas nuevas usando el `id` como marca de agua. Esta opción no captura cambios retroactivos (por ejemplo, actualizaciones de estado), así que se combinaría con una ventana de re-lectura y una reconciliación completa periódica.
- **Clientes y productos:** full refresh diario más un snapshot SCD2 de dbt para conservar el historial de cambios.
- **Tasas de cambio:** llamada diaria programada a la API, solo append. No requiere SCD2 porque las tasas son valores inmutables con fecha propia.

## 2. Transformación de datos

Proyecto dbt: `ecommerce_dbt`, organizado en tres capas.

### Staging

Castea tipos y renombra columnas; sin joins ni reglas de negocio. Un modelo por fuente (5 modelos):

- `stg_customers`
- `stg_orders`
- `stg_order_items`
- `stg_products`
- `stg_fx_rates`

### Intermediate

Lógica de negocio reutilizable: conversión de moneda a USD y flags de calidad. Estos modelos enriquecen los datos que alimentan las tablas de hechos.

| Modelo | Grano | Propósito |
|---|---|---|
| `int_fx_rates_to_usd` | moneda + fecha de tasa | Única fuente de verdad para la conversión a USD, con rangos de vigencia |
| `int_order_items_enriched` | línea de orden | Línea + orden + producto + tasa de cambio; importe en USD y flags de calidad |
| `int_orders_enriched` | orden | Orden + tasa de cambio + totales agregados de sus líneas; flags a nivel orden |

### Marts

Elegí un star schema que mantiene dos tablas de hechos principales (órdenes y líneas de orden) por estos motivos:

- **Granos distintos:** los productos solo existen a nivel de línea (Q1), mientras que el análisis por hora del día necesita una fila por orden (Q2).
- **Ninguna orden se pierde:** 93 órdenes no tienen líneas. Derivar las órdenes desde las líneas dejaría fuera, en silencio, al 20% de ellas en la Q2.
- **Medidas aditivas y seguras:** con un solo grano por tabla, cualquier medida se puede sumar directamente.

**Tasas como tabla de hechos:** `fct_fx_rates` también se modela como hecho, para analizar la evolución de los tipos de cambio.

**Cinco dimensiones:** `dim_products`, `dim_customers`, `dim_currencies`, `dim_date` y `dim_hour`. Las dimensiones de fecha y hora son generadas (no derivadas de los datos) para facilitar el análisis en BI: los días y horas sin ventas aparecen explícitamente con cero.

Por último, dos tablas agregadas, derivadas del star schema, responden las preguntas de negocio.

| Modelo | Tipo | Grano |
|---|---|---|
| `fct_order_items` | Hecho | línea de orden |
| `fct_orders` | Hecho | orden |
| `fct_fx_rates` | Hecho | moneda + fecha de tasa |
| `dim_products` | Dimensión | producto |
| `dim_customers` | Dimensión | cliente |
| `dim_currencies` | Dimensión | código de moneda |
| `dim_date` | Dimensión | día |
| `dim_hour` | Dimensión | hora del día |
| `rpt_product_performance` | Reporte (Q1) | producto |
| `rpt_sales_by_hour` | Reporte (Q2) | hora del día × día de la semana |

## 3. Normalización de moneda

Todo el revenue se convierte a USD. Cada tasa es válida desde su fecha hasta la siguiente tasa de la misma moneda.

La primera tasa de cada moneda se extiende hacia atrás (1900-01-01) para cubrir las órdenes anteriores a la primera respuesta de la API; esas filas se marcan con `is_fx_rate_backfilled`. Las órdenes se cruzan con las tasas mediante una condición de rango (`order_date >= valid_from and order_date < valid_to`), portable a cualquier warehouse; el `ASOF JOIN` de DuckDB sería una alternativa equivalente.

**Reglas de conversión:**

- El revenue de cada línea usa la moneda de la línea, no la de la cabecera de la orden: 114 líneas tienen una moneda distinta a la de su orden.
- Las monedas inválidas (códigos sin ninguna tasa) quedan con importe en USD nulo e `is_valid_currency = false`. Siguen contando para unidades y cantidad de órdenes, pero se excluyen del revenue: nunca se convierten con una tasa estimada.

## 4. Calidad de datos

- **Códigos de moneda inválidos (XYZ, ABC, QWE)** — 17% de las órdenes, 21% de las líneas. Q1 y Q2: revenue subestimado.
- **Productos fuera del catálogo** — 20% de las líneas. Q1: se conservan como miembros "Unknown product", así que no se pierde volumen, pero no tienen nombre ni categoría. 68 de esas 71 líneas también tienen moneda inválida.
- **Órdenes sin líneas** — 20% de las órdenes. Q1: sus ventas no se pueden atribuir a ningún producto, así que el volumen y el revenue por producto quedan subestimados.
- **Moneda de la orden ≠ moneda de la línea** — 114 líneas. Q1: el revenue depende de qué moneda se considere válida; se usa la de la línea.
- **Total de la orden ≠ suma de sus líneas** — 150 órdenes difieren en más de 1. Q2: el revenue por hora se apoya en los totales de cabecera y es menos confiable.
- **Tasas de cambio disponibles solo para dos fechas** — 55 órdenes son anteriores a la primera tasa.
- **Tasas con base GBP solo disponibles para junio** — falta la tasa GBP de septiembre. Impacto menor: todas las órdenes en GBP son anteriores a septiembre.
- **Zona horaria no documentada** — afecta a todas las órdenes. Impacto en Q2.
- **Órdenes únicamente entre las 09:00 y las 18:00** — impacto en Q2.

### Tests bloqueantes (severidad error)

- **`unique` / `not_null` en las claves:** una clave duplicada multiplicaría filas en los joins, lo que afecta la integridad de todo el modelo, no solo las preguntas de negocio.
- **Relación órdenes → clientes:** ninguna orden debería existir sin un cliente válido, aunque esto no afecte las preguntas de negocio.
- **Relación líneas → órdenes:** una línea de orden no puede existir sin su orden; indicaría una extracción incompleta. El chequeo inverso (órdenes sin líneas) es un problema conocido del origen y está en `warn` para no bloquear el pipeline.
- **`quantity` y `unit_price` en las líneas de orden:** no nulos y mayores a cero; una línea sin cantidad o sin precio es inválida.
- **Tasas de cambio:** no se admiten valores nulos, ya que todos los campos son necesarios para realizar la conversión.

## Supuestos

- USD es la moneda de reporte, y el catálogo de productos (`base_price`) está en USD.
- Los códigos sin tasa (`XYZ`, `ABC`, `QWE`) se consideran inválidos.
- Una tasa es válida desde su fecha hasta la siguiente disponible; la primera tasa también se aplica a las órdenes anteriores a ella.
- Para el revenue de cada línea, la moneda de la línea es la fuente de verdad, no la de la cabecera.
- Solo las órdenes `completed` cuentan como revenue (actualmente lo son todas).
- El revenue por producto se calcula desde la tabla de líneas de orden; las 93 órdenes sin líneas quedan fuera de ese cálculo, porque el producto solo existe a nivel de línea.
- Los `product_id` que no están en el catálogo se consideran productos reales todavía no incorporados, así que se mantienen como miembros "Unknown product" en lugar de descartarse.

## Tests propios

- **`positive_value`** (test genérico propio): cantidades, precios, tasas y totales deben ser mayores a cero.
- **`assert_order_items_row_count_preserved`:** líneas enriquecidas = líneas de staging, para que ningún join pierda ni duplique filas.
- **`assert_order_total_matches_lines`:** conciliación entre el total de cabecera y la suma de líneas (problema conocido del origen, `warn`).
- **`assert_fct_items_reconcile_with_fct_orders`:** consistencia entre las dos tablas de hechos.
- **`assert_rpt_product_totals_match_facts`:** totales del reporte = totales del hecho (Q1).