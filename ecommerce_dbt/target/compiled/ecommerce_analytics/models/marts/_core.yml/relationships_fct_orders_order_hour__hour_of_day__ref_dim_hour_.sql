
    
    

with child as (
    select order_hour as from_field
    from "warehouse"."marts"."fct_orders"
    where order_hour is not null
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


