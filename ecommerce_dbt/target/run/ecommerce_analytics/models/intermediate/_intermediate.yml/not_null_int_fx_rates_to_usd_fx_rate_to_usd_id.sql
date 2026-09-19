
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select fx_rate_to_usd_id
from "warehouse"."intermediate"."int_fx_rates_to_usd"
where fx_rate_to_usd_id is null



  
  
      
    ) dbt_internal_test