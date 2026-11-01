-- Q5. Средняя оценка: доставлено вовремя vs с опозданием
-- Отзывы сначала сводим к одному на заказ, иначе JOIN задвоит заказы.
WITH ranked AS (
    SELECT
        order_id,
        review_score,
        ROW_NUMBER() OVER (PARTITION BY order_id ORDER BY review_answer_timestamp DESC) AS rn
    FROM order_reviews
),
last_review AS (
    SELECT order_id, review_score
    FROM ranked
    WHERE rn = 1
),
delivered AS (
    SELECT
        order_id,
        CASE
            WHEN CAST(order_delivered_customer_date AS date)
                 > CAST(order_estimated_delivery_date AS date) THEN 'С опозданием'
            ELSE 'Вовремя'
        END AS delivery
    FROM orders
    WHERE order_status = 'delivered'
      AND order_delivered_customer_date IS NOT NULL
)
SELECT
    d.delivery,
    COUNT(*) AS orders,
    ROUND(AVG(r.review_score), 2) AS avg_score,
    ROUND(100.0 * AVG(CASE WHEN r.review_score <= 2 THEN 1 ELSE 0 END), 1) AS low_score_pct
FROM delivered d
JOIN last_review r ON r.order_id = d.order_id
GROUP BY d.delivery
ORDER BY d.delivery DESC;
