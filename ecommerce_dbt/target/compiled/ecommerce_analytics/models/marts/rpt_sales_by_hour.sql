-- Pregunta de negocio 2: ¿cuál es el mejor horario para lanzar promociones?
-- Grano: un registro por hora del día × día de la semana (24 × 7 = 168 filas).
-- Incluye las combinaciones sin ventas (con 0), para que el dashboard muestre
-- también los horarios vacíos.
--
-- Reglas:
--   - Base: fct_orders (todas las órdenes, incluidas las que no tienen líneas).
--   - Métrica principal: cantidad de órdenes (no afectada por problemas de calidad).
--   - Revenue USD: total de cabecera, solo monedas válidas (ver is_total_reconciled
--     en fct_orders: el total de cabecera no siempre coincide con las líneas).
--   - Zona horaria de los timestamps: no documentada en el origen (supuesto: hora local).

with orders as (

    select
        o.*,
        isodow(o.order_date)        as day_of_week
    from "warehouse"."marts"."fct_orders" as o
    where o.is_revenue_eligible

),

hours as (

    select * from "warehouse"."marts"."dim_hour"

),

weekdays as (

    select distinct day_of_week, day_name, is_weekend
    from "warehouse"."marts"."dim_date"

),

slots as (

    select
        hours.hour_of_day,
        hours.hour_label,
        hours.daypart,
        weekdays.day_of_week,
        weekdays.day_name,
        weekdays.is_weekend
    from hours
    cross join weekdays

),

aggregated as (

    select
        order_hour                                              as hour_of_day,
        day_of_week,
        count(*)                                                as orders,
        count(*) filter (where is_valid_currency)               as orders_with_revenue,
        sum(order_total_usd)                                    as revenue_usd,
        sum(units)                                              as units

    from orders
    group by order_hour, day_of_week

)

select
    slots.day_of_week * 100 + slots.hour_of_day                 as slot_key,
    slots.hour_of_day,
    slots.hour_label,
    slots.daypart,
    slots.day_of_week,
    slots.day_name,
    slots.is_weekend,

    coalesce(aggregated.orders, 0)                              as orders,
    coalesce(aggregated.orders_with_revenue, 0)                 as orders_with_revenue,
    coalesce(aggregated.revenue_usd, 0)                         as revenue_usd,
    coalesce(aggregated.units, 0)                               as units,
    round(aggregated.revenue_usd / nullif(aggregated.orders_with_revenue, 0), 2)
                                                                as avg_order_value_usd,
    round(coalesce(aggregated.orders, 0) / sum(coalesce(aggregated.orders, 0)) over (), 4)
                                                                as share_of_orders

from slots
left join aggregated
    on aggregated.hour_of_day = slots.hour_of_day
    and aggregated.day_of_week = slots.day_of_week