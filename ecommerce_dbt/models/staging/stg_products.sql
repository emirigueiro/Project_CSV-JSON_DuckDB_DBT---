-- un registro por producto del catálogo.

with source as (select * from {{ source('raw', 'products') }}

),

renamed as (select
        cast(id as integer)                     as product_id,
        trim(name)                              as product_name,
        trim(category)                          as category,
        trim(description)                       as product_description,
        cast(base_price as decimal(18, 2))      as base_price,
        upper(trim(currency))                   as base_price_currency_code,
        _loaded_at

    from source

)
select * from renamed
