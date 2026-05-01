view: daily_revenue {
  sql_table_name: `my_project.datamart_02_enriched.agg_daily_revenue` ;;

  dimension_group: date_day {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}.date_day ;;
  }

  dimension: channel {
    type: string
    sql: ${TABLE}.channel ;;
  }

  dimension: country {
    type: string
    sql: ${TABLE}.country ;;
  }

  measure: total_revenue_usd {
    type: sum
    sql: ${TABLE}.total_revenue_usd ;;
    value_format_name: usd
  }

  measure: total_order_count {
    type: sum
    sql: ${TABLE}.order_count ;;
  }

  measure: avg_order_value_usd {
    type: average
    sql: ${TABLE}.avg_order_value_usd ;;
    value_format_name: usd
  }
}
