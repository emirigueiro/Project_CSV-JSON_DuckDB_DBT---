
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select currency_code
from "warehouse"."marts"."fct_fx_rates"
where currency_code is null



  
  
      
    ) dbt_internal_test