-- =============================================================================
-- stg_sql_server_dbo__orders
-- =============================================================================
-- Capa Staging: relación 1:1 con la tabla de Bronze. Solo renombrado y casteado.
-- Aquí no se filtra ni se deduplica: los borrados lógicos se exponen como
-- is_deleted y es Silver quien decide qué hacer con ellos.
-- Los importes llevan el sufijo _usd y los timestamps el sufijo _utc.
-- promo_id y shipping_service llegan como cadena vacía cuando no aplican:
-- los convertimos a nulo para que los joins y los tests se comporten bien.
-- =============================================================================

with source as (
    select * from {{ source('sql_server_dbo', 'orders') }}
),

renamed as (
    select
          order_id
        , user_id
        , address_id
        , nullif(trim(promo_id), '')               as promo_id
        , status                                   as order_status
        , nullif(trim(shipping_service), '')       as shipping_service
        , nullif(trim(tracking_id), '')            as tracking_id
        , created_at                               as created_at_utc
        , estimated_delivery_at                    as estimated_delivery_at_utc
        , delivered_at                             as delivered_at_utc
        , shipping_cost                            as shipping_cost_usd
        , order_cost                               as order_cost_usd
        , order_total                              as order_total_usd
        , coalesce(_fivetran_deleted, false)       as is_deleted
        , _fivetran_synced                         as date_load
    from source
)

select * from renamed
