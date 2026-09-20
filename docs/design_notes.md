## Design Notes

# 1. Data ingestion

The raw source files are loaded into the raw schema of warehouse.duckdb by a Python notebook (ingest/01_ingesta_raw.ipynb), using a full refresh. Ingestion is deliberately kept separate from transformation: the loader only does Extract + Load, and every cleaning step, data type and business rule lives in dbt.

CSV files are loaded as VARCHAR (all_varchar = true). Type inference on dirty data can fail or silently coerce values.
Every table includes two metadata columns: _loaded_at (load timestamp) and _source_file (origin file).
fx_rates.json is not a flat list but an object wrapping an array of API responses. The loader stores one row per API response, keeping the rates map as JSON; it is flattened in staging.

# Production improvements
Orders and order items: log-based CDC if available, since it captures inserts, updates and deletes. Otherwise, a daily incremental extract of new rows using the id as watermark. This option does not capture retroactive changes (e.g. status updates), so it would be combined with a lookback window and a periodic full reconciliation.
Customers and products: daily full refresh plus a dbt SCD2 snapshot to preserve the history of changes.
FX rates: scheduled daily API call, append-only. SCD2 is not required because rates are immutable, dated values.

# 2. Data transformation
dbt project: ecommerce_dbt, organized in three layers.

# Staging
Cast types and rename columns; no joins and no business rules. One model per source (5 models):

stg_customers
stg_orders
stg_order_items
stg_products
stg_fx_rates

# Intermediate
Reusable business logic: currency conversion to USD and data-quality flags. These models enrich the data that feeds the fact tables.

Model	                      Grain     	Purpose
int_fx_rates_to_usd	currency  + rate date	  Single source of truth for conversion to USD, with validity ranges
int_order_items_enriched	  order line	  Line + order + product + FX rate; USD amount and data-quality flags
int_orders_enriched	          order	         Order + FX rate + aggregated line totals; order-level flags

# Marts
I chose a star schema mantain two main facts tables (orers and orders_items) for this reason:

Different grains --> Products only exist at line level (Q1), while the time-of-day analysis needs one row per order (Q2).
No lost orders --> 93 orders have no line items. Deriving orders from lines would silently drop 20% of them from Q2.
Safe, additive measures--> With one grain per table, every measure can be summed directly.

Rates as fact table: fct_fx_rates is also modelled as a fact, to analyse the evolution of exchange rates.

Five dimension tables: dim_products, dim_customers, dim_currencies, dim_date and dim_hour. The date and hour dimensions are generated (not derived from the data) to make BI analysis easier: days and hours without sales appear explicitly with zero.

Finally, two aggregated tables, derived from the star schema, answer the business questions.

Model	                Type	    Grain
fct_order_items	        Fact	    order line
fct_orders	            Fact	    order
fct_fx_rates	        Fact	    currency + rate date
dim_products	        Dimension	product
dim_customers	        Dimension	customer
dim_currencies	        Dimension	currency code
dim_date	            Dimension	day
dim_hour	            Dimension	hour of day
rpt_product_performance	Report     (Q1)	product
rpt_sales_by_hour	    Report     (Q2)	hour of day × day of week

# 3. Currency normalization

All revenue is converted to USD. Each rate is valid from its date until the next rate of the same currency
The earliest rate per currency is extended backwards (1900-01-01) to cover orders placed before the first API response, those rows are flagged with is_fx_rate_backfilled. Orders join to rates with a range condition (order_date >= valid_from and order_date < valid_to), which is portable to any warehouse; DuckDB's ASOF JOIN would be an equivalent alternative.

Conversion rules:
Line revenue uses the line's currency, not the order header's: 114 lines have a different currency from their order.
Invalid currencies (codes without any rate) get a NULL USD amount and is_valid_currency = false. They still count towards units and order counts, but are excluded from revenue: they are never converted with a guessed rate.

# 4. Data quality

* Invalid currency code (XYZ, ABC, QWE) -->	17% of orders, 21% of lines	Q1 and Q2: revenue underestimated.
* Products outside the catalogue -->	20% of lines	Q1: these products are kept as "Unknown product" members, so volume is not lost, but they have no name or category. 68 of these 71 lines also have an invalid currency.
* Orders without line items -->	20% of orders Q1: their sales cannot be attributed to any product, so product volume and revenue are underestimated
* Order currency ≠ line currency --> 114 lines - Q1: revenue depends on which currency is trusted; the line currency is used.
* Order total ≠ sum of its lines -->  150 orders differ by more than 1 - Q2: revenue by hour relies on header totals and is less reliable.
* FX rates available for only two dates -->	55 orders before the first rate .	
GBP-based rates only available for June	GBP rate for September missing	Minor: all GBP orders are before September.
* Undocumented timezone	All orders - Q2 impact.
* Orders only between 09:00 and 18:00 - Q2 impact

# Blocking tests (severity error)
* unique / not_null on keys: a duplicate key would multiply rows in joins, which affects the integrity of the whole model, not only the business questions.
* Orders → customers relationship: no order should exist without a valid customer, even though this does not affect the business questions.
* Order items → orders relationship: an order line cannot exist without its order; it would indicate an incomplete extraction. The reverse check (orders without line items) is a known source issue and is set to warn so it does not block the pipeline.
* quantity and unit_price in order items: not null and greater than zero; a line without quantity or price is invalid.
* FX rates: no null values allowed, since every field is required to perform the conversion.

# Assumptions

USD is the reporting currency, and the product catalogue (`base_price`) is in USD.
codes without a rate (`XYZ`, `ABC`, `QWE`) are treated as invalid.
A rate is valid from its date until the next available rate; the earliest rate is also applied to orders placed before it.
For line revenue, the line currency is the source of truth, not the order header's
Only `completed` orders count as revenue (currently all orders are completed).
Product revenue is computed from the orders lines table, 93 orders have not lines (and I need the line for math de produt id)
Product ids missing from the catalogue are real products not yet in the catalogue, so they are kept as "Unknown product" members instead of being dropped

# Custom tests
positive_value (custom generic test): quantities, prices, rates and totals must be greater than zero.
assert_order_items_row_count_preserved: enriched lines = staging lines, so no rows are lost or duplicated by joins.
assert_order_total_matches_lines: header vs lines reconciliation (known source issue, warn).
assert_fct_items_reconcile_with_fct_orders: consistency between the two fact tables.
assert_rpt_product_totals_match_facts: reporting totals = fact totals (Q1).