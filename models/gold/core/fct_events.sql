-- =============================================================================
-- fct_events
-- =============================================================================
-- Hechos de eventos de navegación. Grano: una fila por evento.
-- =============================================================================

{{
    config(
    materialized='incremental',
    incremental_strategy='microbatch',
    event_time='event_at_utc',
    batch_size='month',
    begin='2024-01-01',
    lookback=1
    )
}}


with events as (
    select * from {{ ref('slv_sql_server_dbo__events') }}
),

final as (
    select
          event_id
        , session_id
        , user_id
        , product_id
        , order_id
        , event_type
        , page_url
        , created_at_utc                            as event_at_utc
        , date_load
    from events
)

select * from final
