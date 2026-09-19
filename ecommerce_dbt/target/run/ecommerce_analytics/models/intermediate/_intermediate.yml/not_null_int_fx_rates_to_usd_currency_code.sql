
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select currency_code
from "warehouse"."intermediate"."int_fx_rates_to_usd"
where currency_code is null



  
  
      
    ) dbt_internal_test