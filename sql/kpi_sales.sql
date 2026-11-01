WITH period_orders AS (
    SELECT order_id, order_status
    FROM orders
    WHERE order_purchase_timestamp >= CAST('{{ period.start }}' AS date)
      AND order_purchase_timestamp < CAST('{{ period.end }}' AS date) + INTERVAL '1' DAY
),
order_revenue AS (
    SELECT po.order_id, SUM(oi.price) AS revenue
    FROM period_orders po
    JOIN order_items oi ON oi.order_id = po.order_id
    WHERE po.order_status NOT IN ('canceled', 'unavailable')
    GROUP BY po.order_id
)
SELECT
    (SELECT COUNT(*) FROM order_revenue) AS orders,
    (SELECT ROUND(SUM(revenue), 0) FROM order_revenue) AS revenue,
    (SELECT ROUND(SUM(revenue) / COUNT(*), 2) FROM order_revenue) AS avg_check,
    (SELECT ROUND(100.0 * AVG(CASE WHEN order_status IN ('canceled', 'unavailable') THEN 1 ELSE 0 END), 2)
     FROM period_orders) AS lost_orders_pct;
