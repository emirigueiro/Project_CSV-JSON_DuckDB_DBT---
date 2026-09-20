-- un registro por cliente.
-- Castea tipos, renombra la clave y normaliza el email.

with source as (select * from {{ source('raw', 'customers') }}),

renamed as (select
        cast(id as integer)               as customer_id,
        trim(name)                         as customer_name,
        lower(trim(email))                 as email,
        cast(registration_date as date)as registered_at,
        trim(country)                       as country,
        _loaded_at

    from source
)
select * from renamed
