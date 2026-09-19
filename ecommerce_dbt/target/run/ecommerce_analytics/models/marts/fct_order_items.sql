
    

    create  table
      "warehouse"."marts"."fct_order_items__dbt_tmp"
  
    
    as (
      -- Hecho de líneas de orden. Grano: un registro por línea de orden.
-- Base de la pregunta de negocio 1 (productos top por volumen y revenue).
--
-- Importes:
--   line_amount               moneda original de la línea
--   line_amount_usd           USD a la tasa vigente en la fecha de la orden
--   line_amount_usd_constant  USD a una tasa de referencia fija
--                             (var fx_constant_rate_date), para aislar el
--                             efecto cambiario
-- Los importes en USD son nulos si la moneda es inválida (is_valid_currency).

with items as (

    select * from "warehouse"."intermediate"."int_order_items_enriched"

),

constant_rates as (

    select currency_code, rate_to_usd
    from "warehouse"."intermediate"."int_fx_rates_to_usd"
    where rate_date = cast('2024-06-01' as date)

)

select
    -- Claves
    items.order_item_id,
    items.order_id,
    items.product_id,
    items.customer_id,
    items.currency_code,
    items.order_date,
    hour(items.ordered_at)                                  as order_hour,

    -- Atributos degenerados
    items.ordered_at,
    items.order_status,

    -- Medidas
    items.quantity,
    items.unit_price,
    items.line_amount,
    items.line_amount_usd,
    cast(items.line_amount * constant_rates.rate_to_usd as decimal(18, 2))
                                                            as line_amount_usd_constant,

    -- Trazabilidad de la conversión
    items.fx_rate_to_usd,
    items.fx_rate_date,
    items.fx_rate_source,

    -- Flags de calidad
    items.is_valid_currency,
    items.is_in_catalogue,
    items.is_currency_mismatch,
    items.is_fx_rate_backfilled,
    items.is_revenue_eligible

from items
left join constant_rates
    on constant_rates.currency_code = items.currency_code
    );
    
  