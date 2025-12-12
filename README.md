# Data Analytics ETL Project

## 📌 Project Overview
This project demonstrates a complete **ETL workflow** (Extract, Transform, Load) using a small star schema model.  
It includes:
- **FactSales** → Sales transactions (fact table).
- **DimCustomer** → Customer information (dimension table).
- **DimProduct** → Product catalog (dimension table).

The dataset contains **intentional data quality issues** (nulls, duplicates, inconsistent formats) to practice cleansing with SQL.

---

## 🗂️ Files Included
- `FactSales.csv` → Raw sales transactions.
- `DimCustomer.csv` → Raw customer data.
- `DimProduct.csv` → Raw product catalog.
- `FactSales_clean.sql` → SQL script to clean and prepare FactSales.
- `DimCustomer_clean.sql` → SQL script to clean and prepare DimCustomer.
- `DimProduct_clean.sql` → SQL script to clean and prepare DimProduct.
- `DataModeling.md` → Documentation explaining schema design and queries.

---

## 🛠️ ETL Workflow

### 1. Extract
Load CSV files into your SQL database:
```sql
LOAD DATA INFILE 'FactSales.csv'
INTO TABLE FactSales
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

## 📌 Conclusions and Project Results

Through this project, we successfully demonstrated a complete ETL workflow on a small star schema.  
Key outcomes include:

- **Data Cleansing Achieved**: Null values were handled, duplicates removed, and inconsistent formats standardized across all tables.  
- **Reliable Star Schema**: The FactSales table was properly linked to DimCustomer and DimProduct, ensuring referential integrity and enabling meaningful analysis.  
- **Business Insights Enabled**: After cleaning, the dataset can answer critical questions such as top customers by spending, best-selling products, and sales distribution by country or category.  
- **Scalable Framework**: The scripts and schema design can be extended with additional dimensions (e.g., Time, Store) to support more advanced analytics and BI dashboards.  
- **Learning Value**: The project provided hands-on practice in SQL-based ETL, data modeling, and quality assurance, building a strong foundation for professional data analysis work.

Overall, the project demonstrates how structured ETL and data modeling transform raw, inconsistent data into a clean, reliable dataset ready for reporting and decision-making.## 🔮 Future Work

While the current project demonstrates a complete ETL workflow and a functional star schema, there are several opportunities to extend and enhance the model:

- **Add DimTime Table**: Introduce a dedicated time dimension (Year, Quarter, Month, Day) to support advanced time-series analysis and seasonal trends.  
- **Add DimStore or DimRegion**: Include store or regional dimensions to analyze sales geographically and compare performance across locations.  
- **Integrate BI Tools**: Connect the cleaned schema to Power BI or Tableau to build interactive dashboards and visualizations.  
- **Automate ETL Pipelines**: Use Python (pandas, SQLAlchemy) or ETL tools (Airflow, SSIS, Talend) to automate data ingestion and transformation.  
- **Data Quality Monitoring**: Implement automated checks and alerts to detect anomalies, duplicates, or missing values in future data loads.  
- **Expand Dataset**: Add more fact tables (e.g., FactReturns, FactInventory) to broaden analytical capabilities.  
- **Snowflake Schema Exploration**: Normalize dimensions further (e.g., splitting Customer into Contact and Location tables) to practice snowflake modeling.

These extensions will make the project more realistic, scalable, and closer to enterprise-level data warehouse design.## 🛠️ Tools Used

This project was built and tested using the following tools and technologies:

- **SQL (MySQL / PostgreSQL / SQL Server)**  
  Used for data extraction, transformation, and loading (ETL). SQL scripts handle cleansing tasks such as null handling, deduplication, normalization, and referential integrity checks.

- **CSV Files**  
  Raw datasets were provided in CSV format (FactSales, DimCustomer, DimProduct). These files simulate real-world messy data with inconsistencies and missing values.

- **Data Modeling (Star Schema)**  
  The schema design follows a star model, with FactSales as the central fact table and DimCustomer/DimProduct as dimension tables. This structure supports efficient analytical queries.

- **Text Editors (VS Code / Notepad++)**  
  Used to edit CSV files, SQL scripts, and documentation (README.md, DataModeling.md).

- **BI Tools (Power BI / Tableau)** *(optional extension)*  
  After cleansing, the data can be connected to BI tools to build dashboards and visualizations for deeper insights.

- **Version Control (GitHub)**  
  The project is organized with a README file and SQL scripts, making it easy to share, collaborate, and track changes.
