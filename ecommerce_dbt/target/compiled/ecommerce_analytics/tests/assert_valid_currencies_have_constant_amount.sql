-- Toda línea con moneda válida debe tener importe a moneda constante.
-- Falla si la tasa de referencia (var fx_constant_rate_date) no existe para
-- alguna moneda, p.ej. si se configura una fecha sin respuesta de la API.

select order_item_id, currency_code
from "warehouse"."marts"."fct_order_items"
where is_valid_currency
  and line_amount_usd_constant is null