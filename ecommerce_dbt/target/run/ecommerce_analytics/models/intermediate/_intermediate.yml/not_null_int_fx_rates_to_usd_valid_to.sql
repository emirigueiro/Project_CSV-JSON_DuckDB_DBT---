
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select valid_to
from "warehouse"."intermediate"."int_fx_rates_to_usd"
where valid_to is null



  
  
      
    ) dbt_internal_test