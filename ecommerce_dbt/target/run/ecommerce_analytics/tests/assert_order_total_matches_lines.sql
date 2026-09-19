
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  -- Órdenes cuyo total de cabecera difiere de la suma de sus líneas en más de
-- 0.05 (tolerancia por redondeo). Problema conocido del origen: se reporta
-- como warning. El revenue por producto se calcula desde las líneas.



select
    order_id,
    order_total_amount,
    lines_amount,
    total_vs_lines_diff

from "warehouse"."intermediate"."int_orders_enriched"
where has_line_items
  and not is_total_reconciled
  
  
      
    ) dbt_internal_test