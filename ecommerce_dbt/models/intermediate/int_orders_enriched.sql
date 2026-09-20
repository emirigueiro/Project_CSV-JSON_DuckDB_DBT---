-- un registro por orden (igual que stg_orders).
-- Convierte el total de cabecera a USD, agrega los totales de sus líneas y
-- Nota: el total de cabecera se compara con la suma de las líneas en moneda

-

with orders as (

    select * from {{ ref('stg_orders') }}

),

fx_rates as (

    select * from {{ ref('int_fx_rates_to_usd') }}

),

line_totals as (select
        order_id,
        count(*)                    as line_count,
        sum(quantity)               as units,
        sum(line_amount)            as lines_amount,
        sum(line_amount_usd)        as lines_amount_usd,
        bool_or(not is_valid_currency)  as has_invalid_currency_lines,
        bool_or(not is_in_catalogue)    as has_unknown_product_lines

    from {{ ref('int_order_items_enriched') }}
    group by order_id

),

joined as (select
        orders.order_id,
        orders.customer_id,
        orders.ordered_at,
        orders.order_date,
        orders.order_status,
        orders.currency_code,
        orders.order_total_amount,

        fx_rates.rate_to_usd       as fx_rate_to_usd,
        fx_rates.rate_date         as fx_rate_date,
        fx_rates.fx_rate_source, 
        
        
        cast(orders.order_total_amount * fx_rates.rate_to_usd as decimal(18, 2))    as order_total_usd,


        coalesce(line_totals.line_count, 0)          as line_count,
        coalesce(line_totals.units, 0)      units,
        line_totals.lines_amount,
        line_totals.lines_amount_usd,
        coalesce(line_totals.has_invalid_currency_lines, false) as has_invalid_currency_lines,
        coalesce(line_totals.has_unknown_product_lines, false)  as has_unknown_product_lines,

        
        line_totals.order_id is not null                as has_line_items

    from orders

    left join fx_rates
        on fx_rates.currency_code = orders.currency_code
        and orders.order_date >= fx_rates.valid_from
        and orders.order_date <  fx_rates.valid_to

    left join line_totals
        on line_totals.order_id = orders.order_id

)

select
    *,
    order_total_amount - lines_amount           as total_vs_lines_diff,

    -- Flags de calidad
    fx_rate_to_usd is not null                    as is_valid_currency,
    coalesce(order_date < fx_rate_date, false)          as is_fx_rate_backfilled,
    case
        when not has_line_items then null
        else abs(order_total_amount - lines_amount) <= 0.05
    end                                                     as is_total_reconciled,
    order_status = 'completed'   as is_revenue_eligible

from joined
