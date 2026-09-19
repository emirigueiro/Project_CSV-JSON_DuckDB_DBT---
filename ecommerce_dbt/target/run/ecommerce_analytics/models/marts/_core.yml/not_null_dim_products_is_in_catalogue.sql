
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select is_in_catalogue
from "warehouse"."marts"."dim_products"
where is_in_catalogue is null



  
  
      
    ) dbt_internal_test