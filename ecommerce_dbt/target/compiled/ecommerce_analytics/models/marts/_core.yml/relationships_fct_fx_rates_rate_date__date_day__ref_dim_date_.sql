
    
    

with child as (
    select rate_date as from_field
    from "warehouse"."marts"."fct_fx_rates"
    where rate_date is not null
),

parent as (
    select date_day as to_field
    from "warehouse"."marts"."dim_date"
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null


