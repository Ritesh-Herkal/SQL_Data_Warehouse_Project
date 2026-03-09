USE DataWareHouse
GO

/**************************************************************************************************
    TABLE        : Bronze.Crm_CustInfo
    PURPOSE      : Data Quality Checks & Cleaning
    TOTAL ROWS   : 18,493
**************************************************************************************************/

SELECT * FROM Bronze.Crm_CustInfo

-- ================================================================================================
-- 01. CHECK FOR DUPLICATES IN PRIMARY KEY COLUMN (cst_id)
-- ================================================================================================

/*
    Objective:
    Identify duplicate customer IDs. Since cst_id is expected to behave like a primary key,
    duplicates indicate data quality issues.

    Approach:
    - Group by cst_id
    - Identify records having COUNT > 1
*/

SELECT 
	cst_id, COUNT(*) as dup_record_count
FROM Bronze.Crm_CustInfo
GROUP BY cst_id
HAVING COUNT(1)>1

/*
Sample Output:
29449  2
29473  2
29433  2
NULL   3
29483  2
29466  3
*/

SELECT * FROM Bronze.Crm_CustInfo
WHERE cst_id IN (29449,29473,29433,29483,29466) or cst_id is null
ORDER BY cst_id

/*
    Resolution Strategy:
    - Keep the most recent record
    - Use ROW_NUMBER(), Partition by cst_id, Order by cst_create_date DESC
*/

SELECT 
	*, 
	ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS RN
FROM Bronze.Crm_CustInfo
ORDER BY CST_ID

-- ================================================================================================
-- 02. CHECK FOR LEADING / TRAILING SPACES IN NAME COLUMNS
-- ================================================================================================

/*
    Objective:
    Identify extra spaces in cst_firstname and cst_lastname.
*/

-- First Name Check
SELECT cst_firstname 
FROM Bronze.Crm_CustInfo
WHERE cst_firstname != TRIM(cst_firstname)

-- Last Name Check
SELECT cst_lastname 
FROM Bronze.Crm_CustInfo
WHERE cst_lastname != TRIM(cst_lastname)

--Solution : Use Trim for those column

SELECT TRIM(cst_firstname) AS cst_firstname, TRIM(cst_lastname) AS cst_lastname
FROM Bronze.Crm_CustInfo

-- ================================================================================================
-- 03. DATA CONSISTENCY CHECK – cst_marital_status
-- ================================================================================================

/*
    Objective:
    Standardize marital status values.
    Issues:
    - Abbreviations (S, M)
    - NULL values
*/

SELECT DISTINCT cst_marital_status
FROM Bronze.Crm_CustInfo

-- Standardization Logic
SELECT
CASE
	WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
	WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
	ELSE 'N/A'
END AS cst_marital_status
FROM Bronze.Crm_CustInfo

-- ================================================================================================
-- 04. DATA CONSISTENCY CHECK – cst_gndr
-- ================================================================================================

/*
    Objective:
    Standardize gender values.
*/

SELECT DISTINCT cst_gndr
FROM Bronze.Crm_CustInfo

-- Standardization Logic
SELECT
CASE
	WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
	WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
	ELSE 'N/A'
END AS cst_gndr
FROM Bronze.Crm_CustInfo

-- ================================================================================================
-- 05. DATE VALIDATION CHECK – cst_create_date
-- ================================================================================================

/*
    Objective:
    Ensure all values in cst_create_date are valid dates.
    - TRY_CONVERT() returns NULL if conversion fails.
*/

SELECT cst_create_date
FROM Bronze.Crm_CustInfo
WHERE 
TRY_CONVERT(date, cst_create_date) IS NULL
AND cst_create_date IS NOT NULL

-- RESULT: No invalid date values found.

-- ================================================================================================
-- FINAL CLEANED DATASET (READY FOR SILVER LAYER)
-- ================================================================================================

/*
    Steps Applied:
    1. Remove duplicate records (keep latest per cst_id)
    2. Trim extra spaces in name columns
    3. Standardize marital status
    4. Standardize gender
    5. Remove NULL customer IDs
*/

WITH Cleaned_Data_Crm_CustInfo AS
(
SELECT 
	cst_id, 
	cst_key,
	
    -- Remove extra spaces
	TRIM(cst_firstname) AS cst_firstname, 
	TRIM(cst_lastname) AS cst_lastname,

	-- Standardize marital status
	CASE
		WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
		WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
		ELSE 'N/A'
	END AS cst_marital_status,

	-- Standardize gender
	CASE
		WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
		WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
		ELSE 'N/A'
	END AS cst_gndr,
	cst_create_date,

	-- Deduplication logic
	ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS RN
FROM
Bronze.Crm_CustInfo
)

SELECT * 
FROM Cleaned_Data_Crm_CustInfo
WHERE 
RN = 1					-- Keep latest record
AND cst_id IS NOT NULL	-- Remove NULL IDs