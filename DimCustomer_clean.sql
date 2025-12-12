/* =========================================================
   File: DimCustomer_clean.sql
   Table: DimCustomer
   Goal: Deduplicate, standardize, and validate customer dimension
   ========================================================= */

/* 1) Working copy */
DROP TABLE IF EXISTS DimCustomer_Work;
CREATE TABLE DimCustomer_Work AS
SELECT * FROM DimCustomer;

/* 2) Audit profile */
DROP TABLE IF EXISTS DimCustomer_Audit;
CREATE TABLE DimCustomer_Audit AS
SELECT
  COUNT(*) AS row_count,
  SUM(CASE WHEN Email IS NULL OR Email = '' THEN 1 ELSE 0 END) AS null_email,
  SUM(CASE WHEN Phone IS NULL OR Phone = '' THEN 1 ELSE 0 END) AS null_phone,
  SUM(CASE WHEN Country IS NULL OR Country = '' THEN 1 ELSE 0 END) AS null_country,
  COUNT(*) - COUNT(DISTINCT Email) AS duplicate_emails,
  COUNT(*) - COUNT(DISTINCT CustomerID) AS duplicate_ids
FROM DimCustomer_Work;

/* 3) Normalize country names */
UPDATE DimCustomer_Work
SET Country = 'Syria'
WHERE LOWER(Country) IN ('sy', 'syria', 'sy ');

UPDATE DimCustomer_Work
SET Country = 'United States'
WHERE LOWER(Country) IN ('us', 'usa');

UPDATE DimCustomer_Work
SET Country = 'United Kingdom'
WHERE LOWER(Country) IN ('uk', 'united kingdom');

/* 4) Basic phone normalization:
   - Remove spaces
   - Replace leading '00' with '+'
   Note: Use regex functions if available (PostgreSQL: regexp_replace; SQL Server: REPLACE chain)
*/
UPDATE DimCustomer_Work
SET Phone = REPLACE(Phone, ' ', '');

UPDATE DimCustomer_Work
SET Phone = CONCAT('+', SUBSTRING(Phone, 3))
WHERE Phone LIKE '00%';

/* 5) Email trimming and lower-casing for dedup check */
UPDATE DimCustomer_Work
SET Email = LOWER(TRIM(Email));

/* 6) Deduplication strategy:
   - Keep the first occurrence per Email (assume Email is unique business key)
   - Build a survivor set then load clean table
*/
DROP TABLE IF EXISTS DimCustomer_Survivor;
CREATE TABLE DimCustomer_Survivor AS
SELECT
  MIN(CustomerID) AS CustomerID, -- prefer smallest ID as canonical
  Email
FROM DimCustomer_Work
WHERE Email IS NOT NULL AND Email <> ''
GROUP BY Email;

/* 7) Construct cleaned table with constraints */
DROP TABLE IF EXISTS DimCustomer_Clean;
CREATE TABLE DimCustomer_Clean (
  CustomerID   VARCHAR(10) PRIMARY KEY,
  Name         VARCHAR(100) NOT NULL,
  Email        VARCHAR(120) UNIQUE NOT NULL,
  Phone        VARCHAR(30),
  Country      VARCHAR(50) NOT NULL
);

/* 8) Load cleaned records joining survivor keys */
INSERT INTO DimCustomer_Clean (CustomerID, Name, Email, Phone, Country)
SELECT
  s.CustomerID,
  w.Name,
  w.Email,
  w.Phone,
  COALESCE(w.Country, 'Unknown')
FROM DimCustomer_Work w
JOIN DimCustomer_Survivor s ON w.Email = s.Email
WHERE w.Email IS NOT NULL AND w.Email <> '' ;

/* 9) Handle records missing Email (optional policy)
   Assign synthetic email or exclude; here we exclude from clean load but track separately.
*/
DROP TABLE IF EXISTS DimCustomer_Exceptions;
CREATE TABLE DimCustomer_Exceptions AS
SELECT *
FROM DimCustomer_Work
WHERE Email IS NULL OR Email = '' ;

/* 10) Tests */
-- Uniqueness test on Email
SELECT Email, COUNT(*) AS cnt
FROM DimCustomer_Clean
GROUP BY Email
HAVING COUNT(*) > 1;

-- Country standardization check
SELECT DISTINCT Country
FROM DimCustomer_Clean
ORDER BY Country;

-- Phone format quick check
SELECT CustomerID, Phone
FROM DimCustomer_Clean
WHERE Phone LIKE '00%' OR Phone LIKE '% %';

/* 11) Indexes for joins */
CREATE INDEX idx_dimcustomer_email ON DimCustomer_Clean (Email);
CREATE INDEX idx_dimcustomer_country ON DimCustomer_Clean (Country);
