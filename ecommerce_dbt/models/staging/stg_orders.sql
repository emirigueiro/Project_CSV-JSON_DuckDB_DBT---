-- un registro por orden (cabecera).



with source as (select * from {{ source('raw', 'orders') }}),

renamed as (select
        cast(id as integer)                     as order_id,
        cast(customer_id as integer)            as customer_id,
        cast(order_date as timestamp)           as ordered_at,
        cast(order_date as date)                as order_date,
        cast(total_amount as decimal(18, 2))    as order_total_amount,
        upper(trim(currency))                   as currency_code,
        lower(trim(status))                     as order_status,
        _loaded_at

    from source)

select * from renamed
