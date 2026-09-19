
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  

select *
from "warehouse"."marts"."fct_fx_rates"
where rate_to_usd <= 0


  
  
      
    ) dbt_internal_test