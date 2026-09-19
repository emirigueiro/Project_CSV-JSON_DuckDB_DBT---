
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select is_in_catalogue
from "warehouse"."intermediate"."int_order_items_enriched"
where is_in_catalogue is null



  
  
      
    ) dbt_internal_test