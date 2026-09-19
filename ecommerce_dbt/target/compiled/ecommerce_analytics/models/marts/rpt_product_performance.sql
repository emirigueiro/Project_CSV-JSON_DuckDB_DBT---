-- Pregunta de negocio 1: ¿qué productos son los top performers en volumen y revenue?
-- Grano: un registro por producto (incluye productos fuera de catálogo).
--
-- Reglas:
--   - Solo órdenes con revenue elegible (status completed).
--   - Volumen (unidades): cuenta TODAS las líneas, también las de moneda inválida.
--   - Revenue USD: solo líneas con moneda válida; revenue_coverage_pct indica
--     qué parte de las líneas del producto pudo convertirse.

with items as (

    select * from "warehouse"."marts"."fct_order_items"
    where is_revenue_eligible

),

products as (

    select * from "warehouse"."marts"."dim_products"

),

aggregated as (

    select
        product_id,
        sum(quantity)                                           as units_sold,
        count(*)                                                as order_lines,
        count(distinct order_id)                                as orders,
        count(*) filter (where is_valid_currency)               as order_lines_with_revenue,
        coalesce(sum(line_amount_usd), 0)                       as revenue_usd,
        coalesce(sum(line_amount_usd_constant), 0)              as revenue_usd_constant,
        sum(quantity) filter (where is_valid_currency)          as units_with_revenue

    from items
    group by product_id

)

select
    products.product_id,
    products.product_name,
    products.category,
    products.is_in_catalogue,

    aggregated.units_sold,
    aggregated.order_lines,
    aggregated.orders,
    aggregated.revenue_usd,
    aggregated.revenue_usd_constant,
    aggregated.revenue_usd - aggregated.revenue_usd_constant            as fx_effect_usd,
    round(aggregated.revenue_usd / nullif(aggregated.units_with_revenue, 0), 2)
                                                                        as avg_unit_price_usd,
    round(aggregated.order_lines_with_revenue / aggregated.order_lines, 4)
                                                                        as revenue_coverage_pct,

    round(aggregated.units_sold / sum(aggregated.units_sold) over (), 4)
                                                                        as share_of_units,
    round(aggregated.revenue_usd / sum(aggregated.revenue_usd) over (), 4)
                                                                        as share_of_revenue,

    rank() over (order by aggregated.units_sold desc)                   as rank_by_units,
    rank() over (order by aggregated.revenue_usd desc)                  as rank_by_revenue

from aggregated
join products
    on products.product_id = aggregated.product_id