with

order_items as (

    select * from {{ ref('stg_order_items') }}

),

orders as (

    select * from {{ ref('stg_orders') }}

),

products as (

    select * from {{ ref('stg_products') }}

),

supplies_per_product as (

    select
        product_id,
        sum(supply_cost) as supply_cost

    from {{ ref('stg_supplies') }}

    group by product_id

),

order_items_enriched as (

    select
        order_items.order_item_id,
        order_items.order_id,
        order_items.product_id,
        products.product_name,
        products.product_type,
        products.product_price,
        products.is_food_item,
        products.is_drink_item,
        supplies_per_product.supply_cost

    from order_items

    left join products
        on order_items.product_id = products.product_id

    left join supplies_per_product
        on order_items.product_id = supplies_per_product.product_id

),

order_items_summary as (

    select
        order_id,
        count(*) as count_order_items,
        sum(supply_cost) as supply_cost,
        sum(case when is_food_item then 1 else 0 end) as count_food_items,
        sum(case when is_drink_item then 1 else 0 end) as count_drink_items

    from order_items_enriched

    group by order_id

),

orders_joined as (

    select
        orders.order_id,
        orders.location_id,
        orders.customer_id,
        orders.order_total,
        orders.tax_paid,
        orders.subtotal,
        orders.ordered_at,
        order_items_summary.count_order_items,
        order_items_summary.supply_cost,
        order_items_summary.count_food_items,
        order_items_summary.count_drink_items,
        order_items_summary.count_food_items > 0 as is_food_order,
        order_items_summary.count_drink_items > 0 as is_drink_order

    from orders

    left join order_items_summary
        on orders.order_id = order_items_summary.order_id

),

final as (

    select
        order_id,
        location_id,
        customer_id,
        order_total,
        tax_paid,
        subtotal,
        ordered_at,
        count_order_items,
        supply_cost,
        count_food_items,
        count_drink_items,
        is_food_order,
        is_drink_order,
        row_number() over (
            partition by customer_id
            order by ordered_at
        ) as customer_order_number

    from orders_joined

)

select * from final
