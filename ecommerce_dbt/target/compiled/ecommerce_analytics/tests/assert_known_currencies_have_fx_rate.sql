-- Si una moneda existe en la API de tipo de cambio, toda línea en esa moneda
-- debe haber recibido una tasa. Una falla indica un hueco en los rangos de
-- vigencia (no una moneda inválida, que se maneja con is_valid_currency).

select
    items.order_item_id,
    items.currency_code,
    items.order_date

from "warehouse"."intermediate"."int_order_items_enriched" as items
where items.fx_rate_to_usd is null
  and items.currency_code in (
      select distinct currency_code from "warehouse"."intermediate"."int_fx_rates_to_usd"
  )