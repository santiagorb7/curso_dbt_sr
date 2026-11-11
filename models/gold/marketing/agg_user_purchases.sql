-- =============================================================================
-- agg_user_purchases
-- =============================================================================
-- Agregado de compras por usuario para el equipo de Marketing.
-- Grano: una fila por usuario (incluidos los que nunca han comprado).
-- =============================================================================

with users as (
    select * from {{ ref('dim_users') }}
),

orders as (
    select * from {{ ref('fct_orders') }}
),

order_items as (
    select * from {{ ref('fct_order_items') }}
),

order_metrics as (
    select
          user_id
        , count(distinct order_id)                  as total_orders
        , sum(total_order_cost_usd)                 as total_spent_usd
        , sum(discount_usd)                         as total_discount_usd
        , sum(net_order_cost_usd)                   as total_net_spent_usd
        , min(order_created_at_utc)                 as first_order_at_utc
        , max(order_created_at_utc)                 as last_order_at_utc
    from orders
    group by user_id
),

product_metrics as (
    select
          user_id
        , sum(quantity_units)                       as total_units_bought
        , count(distinct product_id)                as total_distinct_products
    from order_items
    group by user_id
),

final as (
    select
          u.user_id
        , u.full_name
        , u.email
        , u.is_valid_email_address
        , u.country
        , u.continent
        , u.registered_at_utc
        , coalesce(om.total_orders, 0)              as total_orders
        , coalesce(om.total_spent_usd, 0)           as total_spent_usd
        , coalesce(om.total_discount_usd, 0)        as total_discount_usd
        , coalesce(om.total_net_spent_usd, 0)       as total_net_spent_usd
        , coalesce(pm.total_units_bought, 0)        as total_units_bought
        , coalesce(pm.total_distinct_products, 0)   as total_distinct_products
        , om.first_order_at_utc
        , om.last_order_at_utc
        , case
            when om.total_orders is null then 'never_bought'
            when om.total_orders = 1     then 'one_purchase'
            when om.total_orders = 2     then 'two_purchases'
            else 'three_or_more'
          end                                       as purchase_segment
    from users u
    left join order_metrics   om on u.user_id = om.user_id
    left join product_metrics pm on u.user_id = pm.user_id
)

select * from final
