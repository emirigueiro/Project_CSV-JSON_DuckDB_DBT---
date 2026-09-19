
    

    create  table
      "warehouse"."marts"."fct_orders__dbt_tmp"
  
    
    as (
      -- Hecho de órdenes. Grano: un registro por orden (incluye las 93 sin líneas).
-- Base de la pregunta de negocio 2 (mejor horario para promociones).
-- order_total_usd sale del total de cabecera; ver is_total_reconciled.

with orders as (

    select * from "warehouse"."intermediate"."int_orders_enriched"

),

constant_rates as (

    select currency_code, rate_to_usd
    from "warehouse"."intermediate"."int_fx_rates_to_usd"
    where rate_date = cast('2024-06-01' as date)

)

select
    -- Claves
    orders.order_id,
    orders.customer_id,
    orders.currency_code,
    orders.order_date,
    hour(orders.ordered_at)                                 as order_hour,

    -- Atributos degenerados
    orders.ordered_at,
    orders.order_status,

    -- Medidas
    orders.order_total_amount,
    orders.order_total_usd,
    cast(orders.order_total_amount * constant_rates.rate_to_usd as decimal(18, 2))
                                                            as order_total_usd_constant,
    orders.line_count,
    orders.units,
    orders.lines_amount,
    orders.lines_amount_usd,
    orders.total_vs_lines_diff,

    -- Trazabilidad de la conversión
    orders.fx_rate_to_usd,
    orders.fx_rate_date,
    orders.fx_rate_source,

    -- Flags de calidad
    orders.is_valid_currency,
    orders.has_line_items,
    orders.is_total_reconciled,
    orders.has_invalid_currency_lines,
    orders.has_unknown_product_lines,
    orders.is_fx_rate_backfilled,
    orders.is_revenue_eligible

from orders
left join constant_rates
    on constant_rates.currency_code = orders.currency_code
    );
    
  