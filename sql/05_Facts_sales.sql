-- 05. FACT SALES
USE DATABASE Global_superstore;
USE WAREHOUSE SUPERSTORE_WH;
USE SCHEMA ANALYTICALS;

CREATE OR REPLACE TABLE FACT_SALES
(
    sales_key INT AUTOINCREMENT,
    row_id INT,
    customer_key INT,
    product_key INT,
    location_key INT,
    date_key INT,
    order_id VARCHAR,
    ship_mode VARCHAR,
    order_priority VARCHAR,
    sales NUMBER(18,2),
    quantity INTEGER,
    discount NUMBER(10,4),
    profit NUMBER(18,2),
    shipping_cost NUMBER(18,2)
);

INSERT INTO FACT_SALES
(
    row_id,
    customer_key,
    product_key,
    location_key,
    date_key,
    order_id,
    ship_mode,
    order_priority,
    sales,
    quantity,
    discount,
    profit,
    shipping_cost
)
SELECT
    r.row_id,
    c.customer_key,
    p.product_key,
    l.location_key,
    TO_NUMBER(TO_CHAR(r.order_date, 'YYYYMMDD')) AS date_key,
    r.order_id,
    r.ship_mode,
    r.order_priority,
    r.sales,
    r.quantity,
    r.discount,
    r.profit,
    r.shipping_cost
FROM RAW.ORDERS_RAW r
LEFT JOIN DIM_CUSTOMER c
    ON r.customer_id = c.customer_id
LEFT JOIN DIM_PRODUCT p
    ON r.product_id = p.product_id
    AND r.product_name = p.product_name
    AND r.category = p.category
    AND r.sub_category = p.sub_category
LEFT JOIN DIM_LOCATION l
    ON COALESCE(r.city, '') = COALESCE(l.city, '')
    AND COALESCE(r.state, '') = COALESCE(l.state, '')
    AND COALESCE(r.country, '') = COALESCE(l.country, '')
    AND COALESCE(r.postal_code, '') = COALESCE(l.postal_code, '')
    AND COALESCE(r.market, '') = COALESCE(l.market, '')
    AND COALESCE(r.region, '') = COALESCE(l.region, '');

SELECT COUNT(*) FROM FACT_SALES;

SELECT
    COUNT(*) AS TOTAL_ROWS,
    COUNT(DISTINCT row_id) AS UNIQUE_ROW_IDS
FROM FACT_SALES;

-- Referential integrity checks
SELECT
    COUNT_IF(customer_key IS NULL) AS NULL_CUSTOMER_KEYS,
    COUNT_IF(product_key IS NULL) AS NULL_PRODUCT_KEYS,
    COUNT_IF(location_key IS NULL) AS NULL_LOCATION_KEYS,
    COUNT_IF(date_key IS NULL) AS NULL_DATE_KEYS
FROM FACT_SALES;
