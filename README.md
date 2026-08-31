# Global Superstore — Snowflake Data Warehouse & Sales Analytics

## 📌 Project Overview

This project builds an end-to-end **Sales Data Warehouse** using the Global Superstore dataset.

The project demonstrates the complete data pipeline from **raw CSV data → Python/Pandas → Snowflake → Star Schema → SCD Type 1 & Type 2 → Streams → Tasks → Power BI analytics**.

The goal is to transform raw sales data into a structured analytical data warehouse and automate incremental customer data processing using Snowflake.

---

## 🎯 Project Objective

The main objectives of this project are to:

- Explore and clean raw sales data using Python and Pandas
- Load cleaned data into Snowflake
- Build a structured data warehouse using a Star Schema
- Create fact and dimension tables
- Implement Slowly Changing Dimensions (SCD) Type 1 and Type 2
- Capture incremental changes using Snowflake Streams
- Automate data processing using Snowflake Tasks
- Perform business analysis using SQL
- Build an interactive Power BI dashboard

---

# 🏗️ Architecture

```text
                    Global Superstore CSV
                             │
                             ▼
                     Python + Pandas
                             │
                    Data Exploration
                             │
                       Data Cleaning
                             │
                             ▼
                   Snowflake Internal Stage
                             │
                             ▼
                         RAW Layer
                             │
                      ORDERS_RAW
                             │
                             ▼
                     Data Transformation
                             │
                             ▼
                       Star Schema
                             │
            ┌────────────────┼────────────────┐
            │                │                │
            ▼                ▼                ▼
      DIM_CUSTOMER     DIM_PRODUCT     DIM_LOCATION
            │
            ▼
        DIM_DATE
            │
            └───────────────┐
                            ▼
                       FACT_SALES
                            │
                            ▼
                  SCD Type 1 & Type 2
                            │
                            ▼
                      Snowflake Stream
                            │
                            ▼
                       Snowflake Task
                            │
                            ▼
                  Incremental Processing
                            │
                            ▼
                        Power BI
                            │
                            ▼
                   Sales Dashboard
```

---

# 🛠️ Technologies Used

### Programming

- Python
- Pandas
- NumPy

### Data Warehouse

- Snowflake
- Snowflake SQL

### Data Engineering

- Star Schema
- Fact Tables
- Dimension Tables
- Surrogate Keys
- SCD Type 1
- SCD Type 2
- Snowflake Streams
- Snowflake Tasks
- Internal Stages
- File Formats
- `COPY INTO`

### Visualization

- Microsoft Power BI

### Version Control

- Git
- GitHub

### Development

- VS Code

---

# 📊 Dataset

The project uses the **Global Superstore Dataset**.

The dataset contains sales transactions with information about:

- Orders
- Customers
- Products
- Locations
- Sales
- Quantity
- Discounts
- Profit
- Shipping
- Order priority

The main transactional data was loaded into the Snowflake RAW layer.

Dataset source:

Kaggle — Global Superstore Dataset

https://www.kaggle.com/datasets/apoorvaappz/global-super-store-dataset

---

# 🐍 Python & Pandas

Python and Pandas were used during the initial data preparation stage.

### Data Exploration

The dataset was analyzed using:

```python
df.shape
df.columns.tolist()
df.head()
df.info()
df.isna().sum()
df.duplicated().sum()
```

This helped identify:

- Number of records
- Available columns
- Data types
- Missing values
- Duplicate records
- Date fields
- Customer information
- Product information
- Sales metrics

### Data Cleaning

The data preparation process included:

- Duplicate validation
- Missing-value analysis
- Date validation
- Data type validation
- Column standardization
- Data-quality checks

The cleaned dataset was then prepared for Snowflake ingestion.

---

# ❄️ Snowflake Data Warehouse

A Snowflake database was created for the project:

```text
GLOBAL_SUPERSTORE
│
├── RAW
│   └── ORDERS_RAW
│
└── ANALYTICALS
    ├── DIM_CUSTOMER
    ├── DIM_PRODUCT
    ├── DIM_LOCATION
    ├── DIM_DATE
    ├── FACT_SALES
    └── DIM_CUSTOMER_SCD2
```

---

# 📥 Data Ingestion

The cleaned CSV file was uploaded to a Snowflake **Internal Stage**.

A CSV file format was created to define how Snowflake should interpret the incoming file.

Data was loaded into the RAW table using:

```sql
COPY INTO RAW.ORDERS_RAW
FROM @RAW.SUPERSTORE_STAGE
FILE_FORMAT = RAW.CSV_FORMAT;
```

The RAW table preserves the transactional data before analytical transformations.

---

# ⭐ Star Schema

The analytical layer was designed using a **Star Schema**.

## Dimension Tables

### DIM_CUSTOMER

Contains customer information:

```text
CUSTOMER_KEY
CUSTOMER_ID
CUSTOMER_NAME
SEGMENT
```

### DIM_PRODUCT

Contains product information:

```text
PRODUCT_KEY
PRODUCT_ID
PRODUCT_NAME
CATEGORY
SUB_CATEGORY
```

### DIM_LOCATION

Contains geographical information such as:

```text
LOCATION_KEY
CITY
STATE
COUNTRY
POSTAL_CODE
MARKET
REGION
```

### DIM_DATE

Contains date attributes:

```text
DATE_KEY
FULL_DATE
YEAR
QUARTER
MONTH
MONTH_NAME
WEEK
DAY
DAY_NAME
```

## Fact Table

### FACT_SALES

Contains transactional measures including:

```text
SALES
QUANTITY
DISCOUNT
PROFIT
SHIPPING_COST
```

The fact table also contains foreign keys connecting it to the dimension tables.

---

# 🔄 Slowly Changing Dimensions

## SCD Type 1

SCD Type 1 was implemented to demonstrate updating dimension attributes without maintaining historical versions.

Example:

```text
Before:
Customer → Corporate

After:
Customer → Consumer
```

The existing record is overwritten.

### Characteristics

- Existing record is updated
- No historical version is maintained
- Same customer record remains in the dimension

---

# 📚 SCD Type 2

SCD Type 2 was implemented to preserve historical customer changes.

The SCD2 dimension contains:

```text
CUSTOMER_KEY
CUSTOMER_ID
CUSTOMER_NAME
SEGMENT
START_DATE
END_DATE
IS_CURRENT
```

When a customer attribute changes:

```text
Old Record
    ↓
END_DATE populated
    ↓
IS_CURRENT = FALSE
    ↓
New Record inserted
    ↓
IS_CURRENT = TRUE
```

Example:

```text
CUSTOMER_ID | SEGMENT   | IS_CURRENT
-------------------------------------
DB-13060    | Consumer  | FALSE
DB-13060    | Corporate | TRUE
```

This allows the warehouse to preserve historical customer information.

---

# 🌊 Snowflake Streams

Snowflake Streams were used for **change data capture**.

A Stream was created on the incoming customer table:

```text
CUSTOMER_INCOMMING
        ↓
CUSTOMER_INCOMMING_STREAM
```

The Stream captures changes such as:

- INSERT
- UPDATE
- DELETE

For an UPDATE, Snowflake Stream metadata can represent the change through corresponding `INSERT` and `DELETE` records with:

```text
METADATA$ISUPDATE = TRUE
```

This allows downstream processing to identify changed records instead of processing the entire dataset.

---

# ⚙️ Snowflake Tasks

Snowflake Tasks were used to automate processing.

The final pipeline follows:

```text
Incoming Customer Data
          ↓
       Stream
          ↓
         Task
          ↓
    SCD Type 2 Process
          ↓
   DIM_CUSTOMER_SCD2
```

The Task can check whether the Stream contains data and execute the SCD Type 2 processing procedure.

Conceptually:

```text
New Change
    ↓
Stream detects change
    ↓
Task executes
    ↓
Old version is closed
    ↓
New version is inserted
```

This demonstrates incremental and automated ELT processing in Snowflake.

---

# 📈 SQL Analytics

Analytical SQL was used to generate business insights such as:

- Total sales
- Total profit
- Sales by year
- Monthly sales
- Regional sales
- Category performance
- Top-selling products
- Top customers
- Profit analysis
- Discount analysis

These queries were used as the analytical layer before visualization.

---

# 📊 Power BI Dashboard

The final analytical data was connected to Power BI.

The dashboard includes:

### KPI Metrics

- Total Sales
- Total Profit
- Total Quantity
- Total Orders

### Visualizations

- Sales by Year
- Sales by Category
- Sales by Region
- Top 10 Products

### Interactive Filters

- Year
- Category
- Region
- Segment
- Market

The dashboard allows users to interactively analyze sales performance across different business dimensions.

---

# 📁 Project Structure

```text
global-superstore-snowflake-data-warehouse/
│
├── README.md
│
├── python/
│   ├── data_exploration.py
│   └── data_cleaning.py
│
├── sql/
│   ├── 01_database_setup.sql
│   ├── 02_file_format_stage.sql
│   ├── 03_raw_table.sql
│   ├── 04_dimension_tables.sql
│   ├── 05_fact_sales.sql
│   ├── 06_analytical_queries.sql
│   ├── 07_scd_type1.sql
│   ├── 08_scd_type2.sql
│   ├── 09_streams.sql
│   └── 10_tasks.sql
│
└── powerbi/
    └── dashboard.png
```

---

# 🔑 Key Concepts Demonstrated

```text
✔ Python
✔ Pandas
✔ NumPy
✔ SQL
✔ Snowflake
✔ Internal Stage
✔ File Format
✔ COPY INTO
✔ RAW Layer
✔ Star Schema
✔ Fact Tables
✔ Dimension Tables
✔ Surrogate Keys
✔ SCD Type 1
✔ SCD Type 2
✔ Streams
✔ Tasks
✔ Stored Procedures
✔ Incremental Processing
✔ Power BI
✔ Git
✔ GitHub
```

---

# 💡 Business Insights

The project can be used to analyze:

- Which products generate the most sales
- Which categories perform best
- Which regions generate the highest revenue
- Which customers contribute the most sales
- How sales and profit change over time
- The relationship between discounts and profitability
- Product and category performance

---

# 🚀 Project Outcome

This project demonstrates an end-to-end analytical data pipeline starting with raw CSV data and ending with an interactive Power BI dashboard.

The project combines **Python/Pandas for data preparation, Snowflake for data warehousing and automated ELT, SQL for analytics, and Power BI for visualization**.

The implementation of **SCD Type 1, SCD Type 2, Streams, and Tasks** adds incremental processing and historical tracking capabilities to the warehouse.

---

## 👨‍💻 Author

**Nithin Kumar**

Data Analyst / Aspiring Data Engineer

### Technologies

`Python` `Pandas` `SQL` `Snowflake` `Power BI` `Git` `GitHub`
