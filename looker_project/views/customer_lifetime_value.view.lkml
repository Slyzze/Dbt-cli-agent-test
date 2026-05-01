view: customer_lifetime_value {
  sql_table_name: `my_project.datamart_03_consumption.rpt_customer_lifetime_value` ;;

  dimension: customer_id {
    primary_key: yes
    type: string
    sql: ${TABLE}.customer_id ;;
  }

  dimension: country {
    type: string
    sql: ${TABLE}.country ;;
  }

  dimension: plan {
    type: string
    sql: ${TABLE}.plan ;;
  }

  dimension: is_active {
    type: yesno
    sql: ${TABLE}.is_active ;;
  }

  measure: total_spend_usd {
    type: sum
    sql: ${TABLE}.total_spend_usd ;;
    value_format_name: usd
  }

  measure: total_orders {
    type: sum
    sql: ${TABLE}.total_orders ;;
  }

  measure: avg_order_value_usd {
    type: average
    sql: ${TABLE}.avg_order_value_usd ;;
    value_format_name: usd
  }

  dimension: days_since_last_order {
    type: number
    sql: ${TABLE}.days_since_last_order ;;
  }
}
