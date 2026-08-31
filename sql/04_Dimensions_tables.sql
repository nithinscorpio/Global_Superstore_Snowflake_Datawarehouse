-- 04. DIMENSION TABLES
USE DATABASE Global_superstore;
USE WAREHOUSE SUPERSTORE_WH;
USE SCHEMA ANALYTICALS;

-- CUSTOMER DIMENSION
CREATE OR REPLACE TABLE DIM_CUSTOMER(
    customer_key INT AUTOINCREMENT,
    customer_id VARCHAR,
    customer_name VARCHAR,
    segment VARCHAR
);

INSERT INTO DIM_CUSTOMER(
    customer_id,
    customer_name,
    segment
)
SELECT DISTINCT
    customer_id,
    customer_name,
    segment
FROM RAW.ORDERS_RAW
WHERE customer_id IS NOT NULL;

SELECT * FROM DIM_CUSTOMER LIMIT 10;

SELECT
    COUNT(*) AS TOTAL_ROWS,
    COUNT(DISTINCT customer_id) AS UNIQUE_CUSTOMERS
FROM DIM_CUSTOMER;

-- PRODUCT DIMENSION
CREATE OR REPLACE TABLE DIM_PRODUCT(
    product_key INT AUTOINCREMENT,
    product_id VARCHAR,
    product_name VARCHAR,
    category VARCHAR,
    sub_category VARCHAR
);

INSERT INTO DIM_PRODUCT(
    product_id,
    product_name,
    category,
    sub_category
)
SELECT DISTINCT
    product_id,
    product_name,
    category,
    sub_category
FROM RAW.ORDERS_RAW
WHERE product_id IS NOT NULL;

SELECT * FROM DIM_PRODUCT LIMIT 10;

SELECT
    COUNT(*) AS TOTAL_ROWS,
    COUNT(DISTINCT product_id) AS UNIQUE_PRODUCTS
FROM DIM_PRODUCT;

-- LOCATION DIMENSION
CREATE OR REPLACE TABLE DIM_LOCATION(
    location_key INT AUTOINCREMENT,
    city VARCHAR,
    state VARCHAR,
    country VARCHAR,
    postal_code VARCHAR,
    market VARCHAR,
    region VARCHAR
);

INSERT INTO DIM_LOCATION(
    city,
    state,
    country,
    postal_code,
    market,
    region
)
SELECT DISTINCT
    city,
    state,
    country,
    postal_code,
    market,
    region
FROM RAW.ORDERS_RAW;

SELECT * FROM DIM_LOCATION LIMIT 10;

SELECT COUNT(*) AS TOTAL_ROWS
FROM DIM_LOCATION;

-- DATE DIMENSION
CREATE OR REPLACE TABLE DIM_DATE(
    date_key INT,
    full_date DATE,
    year INT,
    quarter INT,
    month INT,
    month_name VARCHAR,
    week INT,
    day INT,
    day_name VARCHAR
);

SELECT
    MIN(order_date) AS min_date,
    MAX(order_date) AS max_date
FROM RAW.ORDERS_RAW;

INSERT INTO DIM_DATE
SELECT
    TO_NUMBER(TO_CHAR(date_value,'YYYYMMDD')) AS date_key,
    date_value AS full_date,
    YEAR(date_value) AS year,
    QUARTER(date_value) AS quarter,
    MONTH(date_value) AS month,
    MONTHNAME(date_value) AS month_name,
    WEEK(date_value) AS week,
    DAY(date_value) AS day,
    DAYNAME(date_value) AS day_name
FROM (
    SELECT DATEADD(
        DAY,
        SEQ4(),
        (SELECT MIN(order_date) FROM RAW.ORDERS_RAW)
    ) AS date_value
    FROM TABLE(GENERATOR(ROWCOUNT => 5000))
);

SELECT * FROM DIM_DATE LIMIT 10;
