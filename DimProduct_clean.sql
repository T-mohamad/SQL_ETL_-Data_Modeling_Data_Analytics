/* =========================================================
   File: DimProduct_clean.sql
   Table: DimProduct
   Goal: Standardize categories, fix nulls, and deduplicate products
   ========================================================= */

/* 1) Working copy */
DROP TABLE IF EXISTS DimProduct_Work;
CREATE TABLE DimProduct_Work AS
SELECT * FROM DimProduct;

/* 2) Audit */
DROP TABLE IF EXISTS DimProduct_Audit;
CREATE TABLE DimProduct_Audit AS
SELECT
  COUNT(*) AS row_count,
  SUM(CASE WHEN ProductName IS NULL OR ProductName = '' THEN 1 ELSE 0 END) AS null_name,
  SUM(CASE WHEN Category IS NULL OR Category = '' THEN 1 ELSE 0 END) AS null_category,
  SUM(CASE WHEN Price IS NULL OR Price <= 0 THEN 1 ELSE 0 END) AS invalid_price,
  SUM(CASE WHEN Status IS NULL OR Status = '' THEN 1 ELSE 0 END) AS null_status,
  COUNT(*) - COUNT(DISTINCT ProductID) AS duplicate_ids,
  COUNT(*) - COUNT(DISTINCT CONCAT(ProductName, '|', Category)) AS duplicate_name_category
FROM DimProduct_Work;

/* 3) Standardize Category values */
UPDATE DimProduct_Work
SET Category = 'Home Appliance'
WHERE LOWER(REPLACE(Category, ' ', '')) = 'homeappliance';

UPDATE DimProduct_Work
SET Category = 'Electronics'
WHERE LOWER(Category) IN ('electronics', 'electronic');

UPDATE DimProduct_Work
SET Category = 'Furniture'
WHERE LOWER(Category) IN ('furniture');

/* 4) Resolve missing ProductName:
   - If ProductName IS NULL/empty, set to 'Unknown Product' + ProductID
*/
UPDATE DimProduct_Work
SET ProductName = CONCAT('Unknown Product ', ProductID)
WHERE ProductName IS NULL OR ProductName = '';

/* 5) Constrain Status to {Active, Inactive} */
UPDATE DimProduct_Work
SET Status = 'Active'
WHERE LOWER(Status) = 'active';

UPDATE DimProduct_Work
SET Status = 'Inactive'
WHERE LOWER(Status) = 'inactive';

-- Default missing status to 'Inactive' for safety
UPDATE DimProduct_Work
SET Status = 'Inactive'
WHERE Status IS NULL OR Status = '';

/* 6) Price validation:
   - Set negative or zero prices to NULL to exclude or fix later
   - Optional: round to 2 decimals
*/
UPDATE DimProduct_Work
SET Price = NULL
WHERE Price IS NOT NULL AND Price <= 0;

UPDATE DimProduct_Work
SET Price = ROUND(Price, 2)
WHERE Price IS NOT NULL;

/* 7) Deduplicate:
   Business rule: unique by ProductID, or by (ProductName, Category) if IDs duplicate.
   Keep the record with the highest Price (assume latest catalog).
*/
DROP TABLE IF EXISTS DimProduct_Survivor;
CREATE TABLE DimProduct_Survivor AS
SELECT
  ProductID,
  ProductName,
  Category,
  MAX(Price) AS Price,
  MAX(Status) AS Status
FROM (
  SELECT * FROM DimProduct_Work
) t
GROUP BY ProductID, ProductName, Category;

/* 8) Clean table with constraints */
DROP TABLE IF EXISTS DimProduct_Clean;
CREATE TABLE DimProduct_Clean (
  ProductID    VARCHAR(10) PRIMARY KEY,
  ProductName  VARCHAR(120) NOT NULL,
  Category     VARCHAR(60) NOT NULL,
  Price        DECIMAL(10,2) CHECK (Price IS NULL OR Price > 0),
  Status       VARCHAR(20) CHECK (Status IN ('Active','Inactive'))
);

/* 9) Load survivor set (prefer non-null price; if multiple IDs map, keep first by ProductID) */
INSERT INTO DimProduct_Clean (ProductID, ProductName, Category, Price, Status)
SELECT
  s.ProductID,
  s.ProductName,
  s.Category,
  s.Price,
  s.Status
FROM DimProduct_Survivor s;

/* 10) Exceptions: track records with NULL Price or other anomalies */
DROP TABLE IF EXISTS DimProduct_Exceptions;
CREATE TABLE DimProduct_Exceptions AS
SELECT *
FROM DimProduct_Work
WHERE Price IS NULL OR ProductName LIKE 'Unknown Product%';

/* 11) Tests */
-- Category normalization check
SELECT DISTINCT Category
FROM DimProduct_Clean
ORDER BY Category;

-- Status domain test
SELECT Status, COUNT(*) AS cnt
FROM DimProduct_Clean
GROUP BY Status;

-- Duplicate check by (ProductName, Category)
SELECT ProductName, Category, COUNT(*) AS cnt
FROM DimProduct_Clean
GROUP BY ProductName, Category
HAVING COUNT(*) > 1;

-- Price validity
SELECT ProductID, Price
FROM DimProduct_Clean
WHERE Price IS NULL OR Price <= 0;

/* 12) Indexes for joins */
CREATE INDEX idx_dimproduct_category ON DimProduct_Clean (Category);
CREATE INDEX idx_dimproduct_status ON DimProduct_Clean (Status);
