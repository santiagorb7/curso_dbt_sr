-- =============================================================================
-- int_orders__enriched
-- =============================================================================
-- Pedidos enriquecidos con la dirección de envío y el descuento de la
-- promoción. Grano: una fila por pedido.
-- Los pedidos sin promoción tienen promo_id nulo: left join y descuento 0.
-- =============================================================================

with orders as (
    select * from {{ ref('slv_sql_server_dbo__orders') }}
),

addresses as (
    select * from {{ ref('slv_sql_server_dbo__addresses') }}
),

promos as (
    select * from {{ ref('slv_sql_server_dbo__promos') }}
),

final as (
    select
          o.order_id
        , o.user_id
        , o.address_id
        , a.state                                   as shipping_state
        , a.country                                 as shipping_country
        , o.promo_id
        , p.promo_status
        , coalesce(p.discount_usd, 0)               as discount_usd
        , o.order_status
        , o.shipping_service
        , o.tracking_id
        , o.created_at_utc
        , o.estimated_delivery_at_utc
        , o.delivered_at_utc
        , o.shipping_cost_usd
        , o.order_cost_usd
        , o.order_total_usd
        , o.date_load
    from orders o
    left join addresses a on o.address_id = a.address_id
    left join promos    p on o.promo_id   = p.promo_id
)

select * from final
