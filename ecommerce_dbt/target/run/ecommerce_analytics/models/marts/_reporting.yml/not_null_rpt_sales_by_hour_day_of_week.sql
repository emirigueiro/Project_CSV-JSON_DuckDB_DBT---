
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select day_of_week
from "warehouse"."marts"."rpt_sales_by_hour"
where day_of_week is null



  
  
      
    ) dbt_internal_test