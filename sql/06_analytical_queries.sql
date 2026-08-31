-- 06. ANALYTICAL QUERIES
USE DATABASE Global_superstore;
USE WAREHOUSE SUPERSTORE_WH;
USE SCHEMA ANALYTICALS;

-- Basic totals
SELECT
    SUM(sales) AS total_sales,
    SUM(profit) AS total_profit,
    SUM(quantity) AS total_quantity
FROM FACT_SALES;

-- Yearly sales
SELECT
    d.year,
    SUM(f.sales) AS total_sales,
    SUM(f.profit) AS total_profit
FROM FACT_SALES f
JOIN DIM_DATE d
    ON f.date_key = d.date_key
GROUP BY d.year
ORDER BY d.year;

-- Monthly sales
SELECT
    d.year,
    d.month,
    d.month_name,
    SUM(f.sales) AS total_sales,
    SUM(f.profit) AS total_profit
FROM FACT_SALES f
JOIN DIM_DATE d
    ON f.date_key = d.date_key
GROUP BY d.year, d.month, d.month_name
ORDER BY d.year, d.month;

-- Top 10 products
SELECT
    p.category,
    p.sub_category,
    p.product_name,
    SUM(f.sales) AS total_sales,
    SUM(f.profit) AS total_profit
FROM FACT_SALES f
JOIN DIM_PRODUCT p
    ON f.product_key = p.product_key
GROUP BY p.category, p.sub_category, p.product_name
ORDER BY total_sales DESC
LIMIT 10;

-- Top 10 customers
SELECT
    c.customer_name,
    c.segment,
    SUM(f.sales) AS total_sales,
    SUM(f.profit) AS total_profit
FROM FACT_SALES f
JOIN DIM_CUSTOMER c
    ON f.customer_key = c.customer_key
GROUP BY c.customer_name, c.segment
ORDER BY total_sales DESC
LIMIT 10;

-- Top regions
SELECT
    l.country,
    l.region,
    SUM(f.sales) AS total_sales,
    SUM(f.profit) AS total_profit
FROM FACT_SALES f
JOIN DIM_LOCATION l
    ON f.location_key = l.location_key
GROUP BY l.country, l.region
ORDER BY total_sales DESC;

-- Top markets
SELECT
    l.country,
    l.market,
    SUM(f.sales) AS total_sales,
    SUM(f.profit) AS total_profit
FROM FACT_SALES f
JOIN DIM_LOCATION l
    ON f.location_key = l.location_key
GROUP BY l.country, l.market
ORDER BY total_sales DESC;

-- Product dimension quality checks
SELECT
    product_id,
    COUNT(*) AS cnt
FROM DIM_PRODUCT
GROUP BY product_id
HAVING COUNT(*) > 1
ORDER BY cnt DESC;

SELECT
    product_id,
    COUNT(DISTINCT category),
    COUNT(DISTINCT sub_category),
    COUNT(DISTINCT product_name)
FROM DIM_PRODUCT
GROUP BY product_id
HAVING COUNT(DISTINCT category) > 1
    OR COUNT(DISTINCT sub_category) > 1
    OR COUNT(DISTINCT product_name) > 1;

-- Environment checks
SELECT CURRENT_ACCOUNT(), CURRENT_REGION();
SHOW DATABASES;
SHOW WAREHOUSES;
SELECT CURRENT_USER();
