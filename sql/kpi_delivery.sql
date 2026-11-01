WITH ranked AS (
    SELECT
        order_id,
        review_score,
        ROW_NUMBER() OVER (PARTITION BY order_id ORDER BY review_answer_timestamp DESC) AS rn
    FROM order_reviews
),
delivered AS (
    SELECT
        order_id,
        CASE
            WHEN CAST(order_delivered_customer_date AS date)
                 > CAST(order_estimated_delivery_date AS date) THEN 1
            ELSE 0
        END AS is_late,
        EXTRACT(EPOCH FROM order_delivered_customer_date - order_purchase_timestamp) / 86400 AS delivery_days
    FROM orders
    WHERE order_status = 'delivered'
      AND order_delivered_customer_date IS NOT NULL
)
SELECT
    ROUND(100.0 * AVG(d.is_late), 1) AS late_pct,
    ROUND(CAST(AVG(d.delivery_days) AS numeric), 1) AS avg_delivery_days,
    ROUND(AVG(r.review_score), 2) AS avg_score
FROM delivered d
LEFT JOIN ranked r ON r.order_id = d.order_id AND r.rn = 1;
