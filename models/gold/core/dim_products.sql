-- =============================================================================
-- dim_products
-- =============================================================================
-- Dimensión de productos con una categorización del stock.
-- Día 6: el umbral de "poco stock" es la variable de proyecto
-- low_stock_threshold (dbt_project.yml). Se puede cambiar sin tocar SQL:
--   dbt build --select dim_products --vars '{low_stock_threshold: 20}'
-- =============================================================================

with products as (
    select * from {{ ref('slv_sql_server_dbo__products') }}
),

final as (
    select
          product_id
        , product_name
        , unit_price_usd
        , inventory_units
        , case
            when inventory_units = 0 then 'out_of_stock'
            when inventory_units < {{ var('low_stock_threshold') }} then 'low_stock'
            else 'in_stock'
          end                                       as stock_status
        , date_load
    from products
)

select * from final
