connection: "bigquery"

include: "/views/*.view.lkml"

explore: orders {
  label: "Orders"
  description: "Detailed order analysis joined with customers and products"
  
  join: customers {
    type: left_outer
    sql_on: ${orders.customer_sk_id} = ${customers.customer_sk_id} ;;
    relationship: many_to_one
  }

  join: products {
    type: left_outer
    sql_on: ${orders.product_sk_id} = ${products.product_sk_id} ;;
    relationship: many_to_one
  }
}

explore: revenue {
  label: "Daily Revenue"
  description: "Aggregated daily revenue by channel and country"
  from: daily_revenue
}

explore: customer_clv {
  label: "Customer CLV"
  description: "Customer lifetime value and loyalty metrics"
  from: customer_lifetime_value
}
