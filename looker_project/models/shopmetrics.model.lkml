connection: "bigquery"

include: "/views/*.view.lkml"

explore: mart_daily_revenue {
  label: "Daily Revenue"
  description: "Analyze daily revenue by channel and country."
}

explore: mart_customer_lifetime_value {
  label: "Customer Lifetime Value"
  description: "Analyze customer spend and behavior over time."
}
