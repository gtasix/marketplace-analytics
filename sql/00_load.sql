-- docker compose exec db psql -U analyst -d olist -f /sql/00_load.sql

DROP TABLE IF EXISTS order_reviews, order_items, orders;

CREATE TABLE orders (
    order_id text PRIMARY KEY,
    customer_id text,
    order_status text,
    order_purchase_timestamp timestamp,
    order_approved_at timestamp,
    order_delivered_carrier_date timestamp,
    order_delivered_customer_date timestamp,
    order_estimated_delivery_date timestamp
);

CREATE TABLE order_items (
    order_id text REFERENCES orders (order_id),
    order_item_id int,
    product_id text,
    seller_id text,
    shipping_limit_date timestamp,
    price numeric(10, 2),
    freight_value numeric(10, 2),
    PRIMARY KEY (order_id, order_item_id)
);

-- Без PK: review_id в датасете не уникален, и у заказа бывает >1 отзыва (так написано на kaggle)
CREATE TABLE order_reviews (
    review_id text,
    order_id text,
    review_score smallint,
    review_comment_title text,
    review_comment_message text,
    review_creation_date timestamp,
    review_answer_timestamp timestamp
);

COPY orders FROM '/data/olist_orders_dataset.csv' WITH (FORMAT csv, HEADER true);
COPY order_items FROM '/data/olist_order_items_dataset.csv' WITH (FORMAT csv, HEADER true);
COPY order_reviews FROM '/data/olist_order_reviews_dataset.csv' WITH (FORMAT csv, HEADER true);

CREATE INDEX ON order_items (order_id);
CREATE INDEX ON order_reviews (order_id);

SELECT 'orders' AS t, count(*) FROM orders
UNION ALL
SELECT 'order_items', count(*) FROM order_items
UNION ALL
SELECT 'order_reviews', count(*) FROM order_reviews;

-- Проверка уникальности ключей в order_reviews
SELECT
    COUNT(*) AS rows,
    COUNT(DISTINCT review_id) AS uniq_review_id,
    COUNT(DISTINCT order_id) AS uniq_order_id
FROM order_reviews;
