-- Consistencia entre hechos: para cada orden, la suma de line_amount_usd en
-- fct_order_items debe coincidir con lines_amount_usd en fct_orders.
-- Una falla indica que los dos hechos divergieron (lógica duplicada o joins).

with items_by_order as (

    select order_id, sum(line_amount_usd) as items_usd
    from "warehouse"."marts"."fct_order_items"
    group by order_id

)

select
    orders.order_id,
    orders.lines_amount_usd,
    items_by_order.items_usd

from "warehouse"."marts"."fct_orders" as orders
join items_by_order
    on items_by_order.order_id = orders.order_id
where coalesce(orders.lines_amount_usd, 0) <> coalesce(items_by_order.items_usd, 0)