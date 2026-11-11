-- =============================================================================
-- stg_sql_server_dbo__order_items
-- =============================================================================
-- Capa Staging: relación 1:1 con la tabla de Bronze. Solo renombrado y casteado.
-- Aquí no se filtra ni se deduplica: los borrados lógicos se exponen como
-- is_deleted y es Silver quien decide qué hacer con ellos.
-- La tabla no tiene PK propia: construimos una clave sustituta.
-- Día 3: la clave pasa de md5() a mano a dbt_utils.generate_surrogate_key,
-- que además trata los nulos de forma consistente.
-- =============================================================================

with source as (
    select * from {{ source('sql_server_dbo', 'order_items') }}
),

renamed as (
    select
          {{ dbt_utils.generate_surrogate_key(['order_id', 'product_id']) }} as order_item_id
        , order_id
        , product_id
        , quantity
        , coalesce(_fivetran_deleted, false)       as is_deleted
        , _fivetran_synced                         as date_load
    from source
)

select * from renamed
