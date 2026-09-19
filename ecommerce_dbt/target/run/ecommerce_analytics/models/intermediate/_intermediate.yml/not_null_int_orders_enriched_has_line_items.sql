
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select has_line_items
from "warehouse"."intermediate"."int_orders_enriched"
where has_line_items is null



  
  
      
    ) dbt_internal_test