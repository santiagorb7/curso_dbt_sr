-- =============================================================================
-- fct_orders
-- =============================================================================
-- Hechos de pedidos. Grano: una fila por pedido.
-- net_order_cost_usd = total_order_cost_usd - descuento de la promoción.
-- =============================================================================

with orders as (
    select * from {{ ref('int_orders__enriched') }}
),

final as (
    select
          order_id
        , user_id
        , address_id
        , shipping_state
        , shipping_country
        , promo_id
        , order_status
        , shipping_service
        , tracking_id
        , created_at_utc                            as order_created_at_utc
        , estimated_delivery_at_utc
        , delivered_at_utc
        , datediff('day', created_at_utc, delivered_at_utc) as days_to_deliver
        , shipping_cost_usd
        , order_cost_usd
        , order_total_usd                           as total_order_cost_usd
        , discount_usd
        , order_total_usd - discount_usd            as net_order_cost_usd
        , date_load
    from orders
)

select * from final
