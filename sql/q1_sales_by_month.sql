-- Q1. Продажи по месяцам: число заказов, выручка, средний чек
-- Выручка = сумма price по позициям (без доставки freight_value).
-- Отменённые и недоступные заказы не считаем продажами.
-- {{ period.start }} / {{ period.end }} — параметр Redash (date range).
WITH order_revenue AS (
    SELECT
        o.order_id,
        CAST(date_trunc('month', o.order_purchase_timestamp) AS date) AS month,
        SUM(oi.price) AS revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.order_status NOT IN ('canceled', 'unavailable')
      AND o.order_purchase_timestamp >= CAST('{{ period.start }}' AS date)
      AND o.order_purchase_timestamp < CAST('{{ period.end }}' AS date) + INTERVAL '1' DAY
    GROUP BY o.order_id, CAST(date_trunc('month', o.order_purchase_timestamp) AS date)
)
SELECT
    month,
    COUNT(*) AS orders,
    ROUND(SUM(revenue), 0) AS revenue,
    ROUND(SUM(revenue) / COUNT(*), 2) AS avg_check
FROM order_revenue
GROUP BY month
ORDER BY month;
