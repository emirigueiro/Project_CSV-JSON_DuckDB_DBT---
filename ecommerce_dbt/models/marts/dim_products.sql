-- un registro por product_id.
-- Incluye el catálogo completo MÁS un miembro "desconocido" por cada product_id
-- vendido que no existe en el catálogo. Así ninguna venta se pierde y la FK
-- fct_order_items.product_id -> dim_products tiene integridad garantizada.

with catalogue as (

    select
        product_id,
        product_name,
        category,
        product_description,
        base_price,
        base_price_currency_code,
        true                                    as is_in_catalogue

    from {{ ref('stg_products') }}

),

unknown_products as (

    select distinct
        product_id,
        'Unknown product)'   as product_name,
        'Unknown'                               as category,
        cast(null as varchar)                   as product_description,
        cast(null as decimal(18, 2))            as base_price,
        cast(null as varchar)                   as base_price_currency_code,
        false                                   as is_in_catalogue

    from {{ ref('int_order_items_enriched') }}
    where not is_in_catalogue

)

select * from catalogue
union all
select * from unknown_products
