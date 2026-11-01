-- Q4. Распределение оценок 1–5
-- У части заказов несколько отзывов, взят последний отзыв по каждому заказу.
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
)
SELECT
    review_score,
    COUNT(*) AS orders,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS share_pct
FROM last_review
GROUP BY review_score
ORDER BY review_score;
