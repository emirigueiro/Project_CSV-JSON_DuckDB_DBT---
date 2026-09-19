
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select rate_to_usd
from "warehouse"."marts"."fct_fx_rates"
where rate_to_usd is null



  
  
      
    ) dbt_internal_test