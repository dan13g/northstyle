with customers as (
    select *
    from {{ ref('stg_customers') }}
),

filtered as (
    select
        customer_id,
        customer_name,
        created_at,
        cast(created_at as date) as created_date,
        customer_record_id,
        fivetran_synced_at
    from customers
    where not coalesce(is_deleted, false)
)

select *
from filtered
