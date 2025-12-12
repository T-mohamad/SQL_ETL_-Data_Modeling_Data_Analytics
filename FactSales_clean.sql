/* =========================================================
   File: FactSales_clean.sql
   Table: FactSales
   Goal: Clean, prepare, and validate sales fact data
   ========================================================= */

/* 1) Create a working copy to preserve original data */
DROP TABLE IF EXISTS FactSales_Work;
CREATE TABLE FactSales_Work AS
SELECT *
FROM FactSales;

/* 2) Audit: profile common data quality issues */
DROP TABLE IF EXISTS FactSales_Audit;
CREATE TABLE FactSales_Audit AS
SELECT
  COUNT(*) AS row_count,
  SUM(CASE WHEN SaleDate LIKE '%/%' THEN 1 ELSE 0 END) AS mixed_date_formats,
  SUM(CASE WHEN Quantity IS NULL THEN 1 ELSE 0 END) AS null_quantity,
  SUM(CASE WHEN Discount IS NULL THEN 1 ELSE 0 END) AS null_discount,
  SUM(CASE WHEN TotalAmount IS NULL THEN 1 ELSE 0 END) AS null_total,
  SUM(CASE WHEN Quantity <= 0 OR UnitPrice <= 0 THEN 1 ELSE 0 END) AS non_positive_qty_or_price
FROM FactSales_Work;

/* 3) Standardize dates: convert slashed dates to YYYY-MM-DD
   MySQL: STR_TO_DATE; PostgreSQL: TO_DATE; SQL Server: TRY_CONVERT(date, ...)
*/
UPDATE FactSales_Work
SET SaleDate = DATE_FORMAT(STR_TO_DATE(SaleDate, '%Y/%m/%d'), '%Y-%m-%d')
WHERE SaleDate LIKE '%/%' AND STR_TO_DATE(SaleDate, '%Y/%m/%d') IS NOT NULL;

/* 4) Fill missing Discount with 0 (no discount) */
UPDATE FactSales_Work
SET Discount = 0
WHERE Discount IS NULL;

/* 5) Handle missing or invalid Quantity:
   - If Quantity IS NULL, set to 1 (conservative default for training dataset)
   - If Quantity <= 0, set to NULL to flag and handle separately
*/
UPDATE FactSales_Work
SET Quantity = 1
WHERE Quantity IS NULL;

UPDATE FactSales_Work
SET Quantity = NULL
WHERE Quantity IS NOT NULL AND Quantity <= 0;

/* 6) Recompute TotalAmount using normalized inputs:
   TotalAmount = Quantity * UnitPrice * (1 - Discount)
   Only compute when Quantity and UnitPrice are present and positive.
*/
UPDATE FactSales_Work
SET TotalAmount = Quantity * UnitPrice * (1 - Discount)
WHERE Quantity IS NOT NULL AND UnitPrice IS NOT NULL AND UnitPrice > 0;

/* 7) Add technical checks: ensure Discount in [0,1] and cap outliers */
UPDATE FactSales_Work
SET Discount = 0
WHERE Discount < 0;

UPDATE FactSales_Work
SET Discount = 1
WHERE Discount > 1;

/* 8) Optional: normalize numeric precision on TotalAmount */
UPDATE FactSales_Work
SET TotalAmount = ROUND(TotalAmount, 2)
WHERE TotalAmount IS NOT NULL;

/* 9) Create cleaned table with explicit types and constraints */
DROP TABLE IF EXISTS FactSales_Clean;
CREATE TABLE FactSales_Clean (
  SaleID       INT PRIMARY KEY,
  CustomerID   VARCHAR(10) NOT NULL,
  ProductID    VARCHAR(10) NOT NULL,
  SaleDate     DATE NOT NULL,
  Quantity     INT CHECK (Quantity > 0),
  UnitPrice    DECIMAL(10,2) CHECK (UnitPrice > 0),
  Discount     DECIMAL(5,2) CHECK (Discount >= 0 AND Discount <= 1),
  TotalAmount  DECIMAL(12,2) CHECK (TotalAmount >= 0)
);

/* 10) Insert only valid records (strict load) */
INSERT INTO FactSales_Clean
SELECT
  SaleID,
  CustomerID,
  ProductID,
  /* MySQL: CAST(SaleDate AS DATE); PostgreSQL/SQL Server: CAST as DATE as well */
  CAST(SaleDate AS DATE) AS SaleDate,
  Quantity,
  UnitPrice,
  Discount,
  TotalAmount
FROM FactSales_Work
WHERE SaleID IS NOT NULL
  AND CustomerID IS NOT NULL
  AND ProductID IS NOT NULL
  AND SaleDate IS NOT NULL
  AND Quantity IS NOT NULL AND Quantity > 0
  AND UnitPrice IS NOT NULL AND UnitPrice > 0
  AND Discount BETWEEN 0 AND 1
  AND TotalAmount IS NOT NULL AND TotalAmount >= 0;

/* 11) Referential integrity tests (run after dimensions are cleaned)
   Identify fact rows referencing missing dimension keys
*/
-- Missing customers
SELECT fs.SaleID, fs.CustomerID
FROM FactSales_Clean fs
LEFT JOIN DimCustomer_Clean dc ON fs.CustomerID = dc.CustomerID
WHERE dc.CustomerID IS NULL;

-- Missing products
SELECT fs.SaleID, fs.ProductID
FROM FactSales_Clean fs
LEFT JOIN DimProduct_Clean dp ON fs.ProductID = dp.ProductID
WHERE dp.ProductID IS NULL;

/* 12) Consistency tests */
-- Recompute total and compare (should match)
SELECT
  SaleID,
  TotalAmount AS stored_total,
  (Quantity * UnitPrice * (1 - Discount)) AS recomputed_total
FROM FactSales_Clean
WHERE ABS(TotalAmount - (Quantity * UnitPrice * (1 - Discount))) > 0.01;

/* 13) Distribution checks */
SELECT
  COUNT(*) AS rows_clean,
  MIN(SaleDate) AS min_date,
  MAX(SaleDate) AS max_date,
  AVG(Quantity) AS avg_qty,
  AVG(UnitPrice) AS avg_price,
  AVG(Discount) AS avg_discount,
  SUM(TotalAmount) AS sum_total
FROM FactSales_Clean;

/* 14) Indexes for performance */
CREATE INDEX idx_factsales_customer ON FactSales_Clean (CustomerID);
CREATE INDEX idx_factsales_product ON FactSales_Clean (ProductID);
CREATE INDEX idx_factsales_date ON FactSales_Clean (SaleDate);
