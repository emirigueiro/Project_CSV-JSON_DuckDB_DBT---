
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select is_valid_currency
from "warehouse"."marts"."dim_currencies"
where is_valid_currency is null



  
  
      
    ) dbt_internal_test