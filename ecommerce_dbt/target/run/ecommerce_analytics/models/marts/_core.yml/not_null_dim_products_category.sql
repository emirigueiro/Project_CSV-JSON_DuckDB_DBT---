
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select category
from "warehouse"."marts"."dim_products"
where category is null



  
  
      
    ) dbt_internal_test