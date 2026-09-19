
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select currency_code
from "warehouse"."marts"."dim_currencies"
where currency_code is null



  
  
      
    ) dbt_internal_test