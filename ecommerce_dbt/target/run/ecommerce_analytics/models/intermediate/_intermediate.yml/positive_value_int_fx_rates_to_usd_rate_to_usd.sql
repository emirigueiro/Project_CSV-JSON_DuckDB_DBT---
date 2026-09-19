
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  

select *
from "warehouse"."intermediate"."int_fx_rates_to_usd"
where rate_to_usd <= 0


  
  
      
    ) dbt_internal_test