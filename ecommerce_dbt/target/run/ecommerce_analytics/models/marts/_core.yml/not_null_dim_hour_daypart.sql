
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select daypart
from "warehouse"."marts"."dim_hour"
where daypart is null



  
  
      
    ) dbt_internal_test