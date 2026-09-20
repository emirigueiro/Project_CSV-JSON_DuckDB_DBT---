-- Grano: un registro por línea de orden.
-- product_id NO es una FK garantizada en origen: se conserva tal cual y el
-- test de relationships (severidad warn) documenta los productos huérfanos.

with source as (select * from {{ source('raw', 'order_items') }}

),

renamed as (

select
        cast(id as integer)                     as order_item_id,
        cast(order_id as integer)               as order_id,
        cast(product_id as integer)             as product_id,
        cast(quantity as integer)               as quantity,
        cast(unit_price as decimal(18, 2))      as unit_price,
        upper(trim(currency))                   as currency_code,
        _loaded_at

from source
)

select * from renamed
