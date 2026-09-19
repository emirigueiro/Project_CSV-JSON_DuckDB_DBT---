
    
    

select
    hour_of_day as unique_field,
    count(*) as n_records

from "warehouse"."marts"."dim_hour"
where hour_of_day is not null
group by hour_of_day
having count(*) > 1


