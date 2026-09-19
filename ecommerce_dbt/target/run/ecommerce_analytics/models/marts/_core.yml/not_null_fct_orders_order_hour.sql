
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select order_hour
from "warehouse"."marts"."fct_orders"
where order_hour is null



  
  
      
    ) dbt_internal_test