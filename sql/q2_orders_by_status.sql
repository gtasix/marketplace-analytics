-- Q2. Число заказов по статусам за период
SELECT
    order_status,
    COUNT(*) AS orders,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS share_pct
FROM orders
WHERE order_purchase_timestamp >= CAST('{{ period.start }}' AS date)
  AND order_purchase_timestamp < CAST('{{ period.end }}' AS date) + INTERVAL '1' DAY
GROUP BY order_status
ORDER BY orders DESC;
