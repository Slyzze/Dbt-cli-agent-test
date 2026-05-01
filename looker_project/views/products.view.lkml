view: products {
  sql_table_name: `my_project.datamart_01_core.dim_products` ;;

  dimension: product_sk_id {
    primary_key: yes
    type: string
    sql: ${TABLE}.product_sk_id ;;
    hidden: yes
  }

  dimension: product_nk {
    label: "Product ID"
    type: string
    sql: ${TABLE}.product_nk ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}.name ;;
  }

  dimension: category {
    type: string
    sql: ${TABLE}.category ;;
  }

  dimension: unit_price_usd {
    type: number
    sql: ${TABLE}.unit_price_usd ;;
    value_format_name: usd
  }

  dimension: is_active {
    type: yesno
    sql: ${TABLE}.is_active = 'true' ;;
  }
}
