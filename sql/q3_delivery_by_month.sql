-- Q3. Доставка по месяцам покупки: доля опозданий и среднее время доставки
-- Только доставленные заказы с известной датой доставки.
-- Опоздание: день доставки позже обещанного дня.
-- estimated_delivery_date хранится как дата 00:00, поэтому сравниваем даты без времени,
-- иначе доставка в обещанный день днём засчиталась бы как опоздание.
SELECT
    CAST(date_trunc('month', order_purchase_timestamp) AS date) AS month,
    COUNT(*) AS delivered_orders,
    ROUND(100.0 * AVG(
        CASE
            WHEN CAST(order_delivered_customer_date AS date)
                 > CAST(order_estimated_delivery_date AS date) THEN 1
            ELSE 0
        END
    ), 1) AS late_pct,
    ROUND(CAST(AVG(
        EXTRACT(EPOCH FROM order_delivered_customer_date - order_purchase_timestamp) / 86400
    ) AS numeric), 1) AS avg_delivery_days
FROM orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
  AND order_purchase_timestamp >= DATE '2017-01-01'
  AND order_purchase_timestamp < DATE '2018-09-01' -- хвосты 2016 и сен-окт 2018 почти пустые
GROUP BY CAST(date_trunc('month', order_purchase_timestamp) AS date)
ORDER BY month;
