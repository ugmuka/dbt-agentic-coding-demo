with

customers as (

    select * from {{ ref('stg_customers') }}

),

orders as (

    select * from {{ ref('orders') }}

),

customer_orders_agg as (

    select
        customer_id,
        count(*) as count_orders,
        min(ordered_at) as first_ordered_at,
        max(ordered_at) as last_ordered_at,
        sum(subtotal) as lifetime_spend_pretax,
        sum(order_total) as lifetime_spend

    from orders

    group by customer_id

),

final as (

    select

        ----------  ids
        customers.customer_id,

        ---------- text
        customers.customer_name,

        ---------- aggregates
        coalesce(customer_orders_agg.count_orders, 0) as count_orders,
        customer_orders_agg.first_ordered_at,
        customer_orders_agg.last_ordered_at,
        customer_orders_agg.lifetime_spend_pretax,
        customer_orders_agg.lifetime_spend,

        ---------- type
        case
            when coalesce(customer_orders_agg.count_orders, 0) >= 2 then 'returning'
            else 'new'
        end as customer_type

    from customers

    left join customer_orders_agg
        on customers.customer_id = customer_orders_agg.customer_id

)

select * from final
