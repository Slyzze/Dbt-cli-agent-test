view: orders {
  sql_table_name: `my_project.datamart_01_core.fct_orders` ;;

  dimension: order_sk_id {
    primary_key: yes
    type: string
    sql: ${TABLE}.order_sk_id ;;
    hidden: yes
  }

  dimension: order_nk {
    label: "Order ID"
    type: string
    sql: ${TABLE}.order_nk ;;
  }

  dimension: customer_sk_id {
    type: string
    sql: ${TABLE}.customer_sk_id ;;
    hidden: yes
  }

  dimension: product_sk_id {
    type: string
    sql: ${TABLE}.product_sk_id ;;
    hidden: yes
  }

  dimension_group: order {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}.order_date ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}.status ;;
  }

  dimension: channel {
    type: string
    sql: ${TABLE}.channel ;;
  }

  measure: total_amount_usd {
    type: sum
    sql: ${TABLE}.amount_usd ;;
    value_format_name: usd
  }

  measure: order_count {
    type: count
    drill_fields: [order_nk, status, channel]
  }
}
