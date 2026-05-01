view: customers {
  sql_table_name: `my_project.datamart_01_core.dim_customers` ;;

  dimension: customer_sk_id {
    primary_key: yes
    type: string
    sql: ${TABLE}.customer_sk_id ;;
    hidden: yes
  }

  dimension: customer_nk {
    label: "Customer ID"
    type: string
    sql: ${TABLE}.customer_nk ;;
  }

  dimension: email {
    type: string
    sql: ${TABLE}.email ;;
  }

  dimension: country {
    type: string
    sql: ${TABLE}.country ;;
  }

  dimension: plan {
    type: string
    sql: ${TABLE}.plan ;;
  }

  dimension_group: created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.created_at ;;
  }
}
