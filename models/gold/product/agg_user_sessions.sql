-- =============================================================================
-- agg_user_sessions
-- =============================================================================
-- Agregado de sesiones para el equipo de Producto.
-- Grano: una fila por (user_id, session_id).
-- Usa por nombre las columnas *_count que genera int_events__pivoted_by_session.
-- Día 3: la clave sustituta pasa a generarse con dbt_utils.
-- Día 4: la conversión de segundos a minutos pasa a la macro seconds_to_minutes.
-- =============================================================================

with sessions as (
    select * from {{ ref('int_events__pivoted_by_session') }}
),

users as (
    select * from {{ ref('dim_users') }}
),

final as (
    select
          {{ dbt_utils.generate_surrogate_key(['s.user_id', 's.session_id']) }} as user_session_id
        , s.session_id
        , s.user_id
        , u.country                                 as user_country
        , s.session_start_at_utc
        , s.session_end_at_utc
        , s.session_duration_seconds
        , {{ seconds_to_minutes('s.session_duration_seconds') }} as session_duration_minutes
        , s.page_view_count
        , s.add_to_cart_count
        , s.checkout_count
        , s.package_shipped_count
        , s.checkout_count > 0                      as did_session_convert
    from sessions s
    inner join users u on s.user_id = u.user_id
)

select * from final
