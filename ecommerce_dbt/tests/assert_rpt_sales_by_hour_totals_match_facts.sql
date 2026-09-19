-- La suma de órdenes del reporte horario debe coincidir con las órdenes
-- elegibles de fct_orders, y el reporte debe tener exactamente 168 filas (24 × 7).

with report as (

    select sum(orders) as orders, count(*) as slots
    from {{ ref('rpt_sales_by_hour') }}

),

facts as (

    select count(*) as orders
    from {{ ref('fct_orders') }}
    where is_revenue_eligible

)

select *
from report, facts
where report.orders <> facts.orders
   or report.slots <> 168
