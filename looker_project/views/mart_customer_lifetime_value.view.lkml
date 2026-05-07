view: mart_customer_lifetime_value {
  sql_table_name: `astrafy-sandbox-virgile-8dd5.analytics.mart_customer_lifetime_value` ;;

  dimension: customer_sk_id {
    primary_key: yes
    hidden: yes
    type: string
    sql: ${TABLE}.customer_sk_id ;;
  }

  dimension: customer_id {
    type: string
    sql: ${TABLE}.customer_id ;;
    label: "Customer ID"
  }

  dimension: country {
    type: string
    sql: ${TABLE}.country ;;
    label: "Country"
  }

  dimension: plan {
    type: string
    sql: ${TABLE}.plan ;;
    label: "Subscription Plan"
  }

  measure: total_orders {
    type: sum
    sql: ${TABLE}.total_orders ;;
    label: "Total Orders"
  }

  measure: total_spend_usd {
    type: sum
    sql: ${TABLE}.total_spend_usd ;;
    value_format_name: usd
    label: "Total Spend (USD)"
  }

  measure: avg_order_value_usd {
    type: average
    sql: ${TABLE}.avg_order_value_usd ;;
    value_format_name: usd
    label: "Average Order Value (USD)"
  }

  dimension: days_since_last_order {
    type: number
    sql: ${TABLE}.days_since_last_order ;;
    label: "Days Since Last Order"
  }

  dimension: is_active_customer {
    type: yesno
    sql: ${days_since_last_order} <= 90 ;;
    label: "Is Active Customer"
    description: "Placed an order in the last 90 days."
  }
}
