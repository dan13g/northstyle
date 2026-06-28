with customers as (
    select *
    from {{ ref('int_customers') }}
)

select
    customer_id,
    customer_name,
    created_at,
    created_date,
    customer_record_id,
    fivetran_synced_at
from customers
