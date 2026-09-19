
  
  create view "warehouse"."intermediate"."int_order_items_enriched__dbt_tmp" as (
    -- Grano: un registro por línea de orden (igual que stg_order_items).
-- Enriquece cada línea con datos de su orden, el catálogo y la tasa de cambio,
-- calcula el importe en USD y marca cada problema de calidad con un flag.
-- No descarta filas: todos los joins son LEFT JOIN y el grano se protege con
-- tests (unique en order_item_id + test de conteo de filas).

with order_items as (

    select * from "warehouse"."staging"."stg_order_items"

),

orders as (

    select * from "warehouse"."staging"."stg_orders"

),

products as (

    select * from "warehouse"."staging"."stg_products"

),

fx_rates as (

    select * from "warehouse"."intermediate"."int_fx_rates_to_usd"

),

joined as (

    select
        order_items.order_item_id,
        order_items.order_id,
        order_items.product_id,
        orders.customer_id,
        orders.ordered_at,
        orders.order_date,
        orders.order_status,

        order_items.quantity,
        order_items.unit_price,
        order_items.currency_code,
        orders.currency_code                            as order_currency_code,
        order_items.quantity * order_items.unit_price   as line_amount,

        fx_rates.rate_to_usd                            as fx_rate_to_usd,
        fx_rates.rate_date                              as fx_rate_date,
        fx_rates.fx_rate_source,

        products.product_id is not null                 as is_in_catalogue

    from order_items

    left join orders
        on orders.order_id = order_items.order_id

    left join products
        on products.product_id = order_items.product_id

    -- La tasa se toma por la moneda de la LÍNEA (no la de la cabecera)
    -- y por la fecha de la orden, dentro del rango de vigencia.
    left join fx_rates
        on fx_rates.currency_code = order_items.currency_code
        and orders.order_date >= fx_rates.valid_from
        and orders.order_date <  fx_rates.valid_to

)

select
    *,
    cast(line_amount * fx_rate_to_usd as decimal(18, 2))    as line_amount_usd,

    -- Flags de calidad
    fx_rate_to_usd is not null                              as is_valid_currency,
    currency_code <> order_currency_code                    as is_currency_mismatch,
    coalesce(order_date < fx_rate_date, false)              as is_fx_rate_backfilled,
    order_status = 'completed'                              as is_revenue_eligible

from joined
  );
