-- 03. RAW TABLES AND DATA LOAD
USE DATABASE Global_superstore;
USE WAREHOUSE SUPERSTORE_WH;
USE SCHEMA RAW;

CREATE OR REPLACE TABLE ORDERS_RAW (
    row_id INTEGER,
    order_id VARCHAR,
    order_date DATE,
    ship_date DATE,
    ship_mode VARCHAR,
    customer_id VARCHAR,
    customer_name VARCHAR,
    segment VARCHAR,
    city VARCHAR,
    state VARCHAR,
    country VARCHAR,
    postal_code VARCHAR,
    market VARCHAR,
    region VARCHAR,
    product_id VARCHAR,
    category VARCHAR,
    sub_category VARCHAR,
    product_name VARCHAR,
    sales NUMBER(18,2),
    quantity INTEGER,
    discount NUMBER(10,4),
    profit NUMBER(18,2),
    shipping_cost NUMBER(18,2),
    order_priority VARCHAR
);

SHOW TABLES IN SCHEMA RAW;
DESCRIBE TABLE RAW.ORDERS_RAW;

COPY INTO RAW.ORDERS_RAW 
FROM @RAW.SUPERSTORE_STAGE
FILE_FORMAT = (FORMAT_NAME = RAW.CSV_FORMAT)
ON_ERROR = 'ABORT_STATEMENT';

SELECT * FROM RAW.ORDERS_RAW LIMIT 10;

-- Data quality checks
SELECT COUNT(*) FROM RAW.ORDERS_RAW
WHERE POSTAL_CODE IS NULL;

SELECT
    MIN(order_date) AS earliest_date,
    MAX(order_date) AS latest_date 
FROM RAW.ORDERS_RAW;

SELECT order_date, COUNT(*) AS row_count
FROM RAW.ORDERS_RAW
GROUP BY order_date
ORDER BY order_date;

SELECT COUNT(*) AS invalid_dates
FROM RAW.ORDERS_RAW
WHERE ship_date < order_date;

SELECT COUNT(*) AS MISSING_POSTAL_CODE
FROM RAW.ORDERS_RAW
WHERE POSTAL_CODE IS NULL;

SELECT
    COUNT(*) AS TOTAL_ROWS,
    COUNT(DISTINCT row_id) AS UNIQUE_ROWID
FROM RAW.ORDERS_RAW;
