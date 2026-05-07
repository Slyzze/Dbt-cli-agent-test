view: mart_daily_revenue {
  sql_table_name: `astrafy-sandbox-virgile-8dd5.analytics.mart_daily_revenue` ;;

  dimension_group: date_day {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.date_day ;;
    label: "Date"
  }

  dimension: channel {
    type: string
    sql: ${TABLE}.channel ;;
    label: "Acquisition Channel"
  }

  dimension: country {
    type: string
    sql: ${TABLE}.country ;;
    label: "Country"
  }

  measure: order_count {
    type: sum
    sql: ${TABLE}.order_count ;;
    label: "Order Count"
    description: "Number of confirmed and delivered orders."
  }

  measure: total_revenue_usd {
    type: sum
    sql: ${TABLE}.total_revenue_usd ;;
    value_format_name: usd
    label: "Total Revenue (USD)"
    description: "Total net revenue in USD."
  }

  measure: avg_order_value_usd {
    type: average
    sql: ${TABLE}.avg_order_value_usd ;;
    value_format_name: usd
    label: "Average Order Value (USD)"
    description: "Average order value in USD."
  }
}
