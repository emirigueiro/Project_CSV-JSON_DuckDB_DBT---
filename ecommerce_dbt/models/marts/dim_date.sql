

with bounds as (

    select
        date_trunc('year', min(order_date))                          as start_date,
        date_trunc('year', max(order_date)) + interval 1 year        as end_date
    from {{ ref('stg_orders') }}

),

spine as (

    select cast(generate_series as date) as date_day
    from bounds,
        generate_series(bounds.start_date, bounds.end_date - interval 1 day, interval 1 day)

)

select
    date_day,
    year(date_day)                          as year,
    quarter(date_day)                       as quarter,
    month(date_day)                         as month,
    strftime(date_day, '%Y-%m')             as year_month,
    monthname(date_day)                     as month_name,
    weekofyear(date_day)                    as week_of_year,
    isodow(date_day)                        as day_of_week,
    dayname(date_day)                       as day_name,
    isodow(date_day) in (6, 7)              as is_weekend

from spine
