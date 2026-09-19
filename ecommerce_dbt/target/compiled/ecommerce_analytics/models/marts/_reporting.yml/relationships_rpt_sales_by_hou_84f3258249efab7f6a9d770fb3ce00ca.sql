
    
    

with child as (
    select hour_of_day as from_field
    from "warehouse"."marts"."rpt_sales_by_hour"
    where hour_of_day is not null
),

parent as (
    select hour_of_day as to_field
    from "warehouse"."marts"."dim_hour"
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null


