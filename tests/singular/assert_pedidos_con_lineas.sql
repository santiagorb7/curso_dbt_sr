-- =============================================================================
-- Test singular: todo pedido debe tener al menos una línea de pedido.
-- =============================================================================
-- Devuelve los pedidos de fct_orders que no aparecen en fct_order_items.
-- =============================================================================

select
      o.order_id
    , o.order_created_at_utc
from {{ ref('fct_orders') }} o
left join {{ ref('fct_order_items') }} oi on o.order_id = oi.order_id
where oi.order_id is null
