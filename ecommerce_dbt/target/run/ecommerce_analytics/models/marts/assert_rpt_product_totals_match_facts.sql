
    

    create  table
      "warehouse"."marts"."assert_rpt_product_totals_match_facts__dbt_tmp"
  
    
    as (
      -- Las unidades y el revenue totales del reporte de productos deben coincidir
-- con los del hecho (órdenes con revenue elegible). Detecta filas perdidas en
-- el join con dim_products o agregaciones mal hechas.

with report as (

    select sum(units_sold) as units, sum(revenue_usd) as revenue
    from "warehouse"."marts"."rpt_product_performance"

),

facts as (

    select sum(quantity) as units, coalesce(sum(line_amount_usd), 0) as revenue
    from "warehouse"."marts"."fct_order_items"
    where is_revenue_eligible

)

select *
from report, facts
where report.units <> facts.units
   or report.revenue <> facts.revenue
    );
    
  