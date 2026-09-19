-- El modelo enriquecido debe tener exactamente las mismas líneas que staging:
-- ni perdidas (joins mal hechos) ni duplicadas (fan-out por rangos de tasas).
-- Devuelve una fila si los conteos difieren.

with counts as (

    select
        (select count(*) from {{ ref('stg_order_items') }})          as staging_rows,
        (select count(*) from {{ ref('int_order_items_enriched') }}) as enriched_rows

)

select *
from counts
where staging_rows <> enriched_rows
