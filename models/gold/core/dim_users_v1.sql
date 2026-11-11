-- =============================================================================
-- dim_users_v1
-- =============================================================================
-- Dimensión de usuarios, enriquecida con su dirección por defecto.
-- Versión 1 (deprecada: ver deprecation_date en _core__models.yml).
-- =============================================================================

with users as (
    select * from {{ ref('slv_sql_server_dbo__users') }}
),

addresses as (
    select * from {{ ref('dim_addresses') }}
),

final as (
    select
          u.user_id
        , u.first_name
        , u.last_name
        , concat(u.first_name, ' ', u.last_name)            as full_name
        , u.email
        , coalesce(
              regexp_like(u.email, '^[a-z0-9._%+-]+@[a-z0-9.-]+\\.[a-z]{2,}$'),
              false
          )                                                 as is_valid_email_address
        , u.phone_number
        , u.address_id
        , a.address_line
        , a.zipcode::varchar(20)                            as zipcode
        , a.state
        , a.country
        , a.continent
        , u.created_at_utc                                  as registered_at_utc
        , u.updated_at_utc                                  as last_updated_at_utc
        , datediff('day', u.created_at_utc, current_timestamp()) as days_since_registration
        , u.date_load
    from users u
    left join addresses a on u.address_id = a.address_id
)

select * from final
