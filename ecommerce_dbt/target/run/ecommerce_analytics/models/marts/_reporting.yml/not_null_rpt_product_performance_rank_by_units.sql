
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select rank_by_units
from "warehouse"."marts"."rpt_product_performance"
where rank_by_units is null



  
  
      
    ) dbt_internal_test