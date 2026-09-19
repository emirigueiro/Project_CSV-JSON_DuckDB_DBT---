
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select fx_rate_to_usd_id
from "warehouse"."marts"."fct_fx_rates"
where fx_rate_to_usd_id is null



  
  
      
    ) dbt_internal_test