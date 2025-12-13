# Data Analytics ETL Project

## 📌 Project Overview
This project demonstrates a complete **ETL workflow** (Extract, Transform, Load) using a small star schema model.  
It includes:
- **FactSales** → Sales transactions (fact table).
- **DimCustomer** → Customer information (dimension table).
- **DimProduct** → Product catalog (dimension table).

The dataset contains **intentional data quality issues** (nulls, duplicates, inconsistent formats) to practice cleansing with SQL.


This diagram illustrates the Star Schema used in your project. It shows how the tables are connected through foreign key relationships:
🟨 Central Fact Table: FactSales_Clean
- Contains transactional data: sales, quantities, prices, discounts, and totals.
- Has two foreign keys:
- CustomerID → links to DimCustomer.CustomerID
- ProductID → links to DimProduct_Clean.ProductID
🟫 Dimension Table: DimCustomer
- Stores customer attributes: name, email, phone, country.
- CustomerID is the primary key.
🟧 Dimension Table: DimProduct_Clean
- Stores product attributes: name, category, status.
- ProductID is the primary key.
🔗 Relationships
- Arrows show how FactSales_Clean connects to both dimension tables.
- This structure supports efficient analytical queries like:
- Total sales by country
- Top products by revenue
- Customer segmentation by spending

<img width="1536" height="1024" alt="image" src="https://github.com/user-attachments/assets/10aa480b-dda2-49df-96db-081b47eed4f7" />


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
🧭 ETL Workflow Diagram Explanation:

This diagram illustrates the full ETL process (Extract → Transform → Load) used in your data analytics project:

###🔶 1. Extract
- Source: Raw data comes from three CSV files:
- FactSales.csv – sales transactions
- DimCustomer.csv – customer information
- DimProduct.csv – product catalog
- These files contain messy, real-world data with nulls, duplicates, and inconsistent formats.
- 
🟣 2. Transform
- Tool: SQL scripts are used to clean and prepare the data.
- Key transformations include:
- Standardizing date formats (e.g., converting 2025/01/07 to 2025-01-07)
- Handling missing values (e.g., filling null discounts with 0)
- Removing duplicate records (especially in customer and product tables)
- Recalculating TotalAmount using the formula:
Quantity × UnitPrice × (1 - Discount)

🔵 3. Load
- Target: Cleaned data is loaded into new SQL tables:
- FactSales_Clean
- DimCustomer_Clean
- DimProduct_Clean
- These tables are now ready for analysis, reporting, and dashboarding.
- 
⭐ 4. Data Modeling & BI
- The cleaned tables form a Star Schema:
- FactSales_Clean is the central fact table.
- DimCustomer_Clean and DimProduct_Clean are dimension tables.
- This structure supports powerful queries and can be connected to BI tools like Power BI or Tableau for visual insights.


<img width="1024" height="1024" alt="image" src="https://github.com/user-attachments/assets/4eaf06a8-3e4e-4775-bc65-3af47d3dbded" />




## 📌 Conclusions and Project Results

Through this project, we successfully demonstrated a complete ETL workflow on a small star schema.  
Key outcomes include:

- **Data Cleansing Achieved**: Null values were handled, duplicates removed, and inconsistent formats standardized across all tables.  
- **Reliable Star Schema**: The FactSales table was properly linked to DimCustomer and DimProduct, ensuring referential integrity and enabling meaningful analysis.  
- **Business Insights Enabled**: After cleaning, the dataset can answer critical questions such as top customers by spending, best-selling products, and sales distribution by country or category.  
- **Scalable Framework**: The scripts and schema design can be extended with additional dimensions (e.g., Time, Store) to support more advanced analytics and BI dashboards.  
- **Learning Value**: The project provided hands-on practice in SQL-based ETL, data modeling, and quality assurance, building a strong foundation for professional data analysis work.

Overall, the project demonstrates how structured ETL and data modeling transform raw, inconsistent data into a clean, reliable dataset ready for reporting and decision-making.




## 🔮 Future Work

While the current project demonstrates a complete ETL workflow and a functional star schema, there are several opportunities to extend and enhance the model:

- **Add DimTime Table**: Introduce a dedicated time dimension (Year, Quarter, Month, Day) to support advanced time-series analysis and seasonal trends.  
- **Add DimStore or DimRegion**: Include store or regional dimensions to analyze sales geographically and compare performance across locations.  
- **Integrate BI Tools**: Connect the cleaned schema to Power BI or Tableau to build interactive dashboards and visualizations.  
- **Automate ETL Pipelines**: Use Python (pandas, SQLAlchemy) or ETL tools (Airflow, SSIS, Talend) to automate data ingestion and transformation.  
- **Data Quality Monitoring**: Implement automated checks and alerts to detect anomalies, duplicates, or missing values in future data loads.  
- **Expand Dataset**: Add more fact tables (e.g., FactReturns, FactInventory) to broaden analytical capabilities.  
- **Snowflake Schema Exploration**: Normalize dimensions further (e.g., splitting Customer into Contact and Location tables) to practice snowflake modeling.

These extensions will make the project more realistic, scalable, and closer to enterprise-level data warehouse design.



## 🛠️ Tools Used

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
