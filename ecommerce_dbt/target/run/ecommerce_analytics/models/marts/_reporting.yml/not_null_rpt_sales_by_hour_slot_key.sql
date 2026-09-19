
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select slot_key
from "warehouse"."marts"."rpt_sales_by_hour"
where slot_key is null



  
  
      
    ) dbt_internal_test