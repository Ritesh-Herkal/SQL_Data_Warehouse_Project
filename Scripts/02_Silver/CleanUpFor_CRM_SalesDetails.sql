USE DataWareHouse
GO
/*
/**************************************************************************************************
    TABLE        : Bronze.Crm_SalesDetails
    PURPOSE      : Data Quality Checks & Cleaning for Sales Transaction Data
    TOTAL ROWS   : 60,398
**************************************************************************************************/

SELECT * FROM [Bronze].[Crm_SalesDetails]

-- ================================================================================================
-- 01. IDENTIFY PRIMARY KEY STRUCTURE
-- ================================================================================================

/*
    Objective:
    Identify the primary key for the sales table.

    Observation:
    - Total rows = 60,398
    - Distinct order numbers = 27,659

    This indicates that a single order number appears multiple times,
    meaning each order may contain multiple products.

    Conclusion:
    Business Key = (sls_ord_num + sls_prd_key)
*/

SELECT DISTINCT SLS_ORD_NUM 
FROM [Bronze].[Crm_SalesDetails]   -- 27,659 unique orders


-- Investigate duplicate order numbers
SELECT *
FROM [Bronze].[Crm_SalesDetails] 
WHERE SLS_ORD_NUM IN ('SO51176','SO51177','SO51178')
ORDER BY 1


-- Identify duplicate combinations
SELECT 
    SLS_ORD_NUM,
    COUNT(1) AS record_count,
    sls_prd_key
FROM [Bronze].[Crm_SalesDetails]
GROUP BY sls_ord_num, sls_prd_key
HAVING COUNT(1) > 1
ORDER BY 1

-- SO51176
-- SO51177
-- SO51178

-- Final conclusion:
-- Business Key = SLS_ORD_NUM + SLS_PRD_KEY


-- ================================================================================================
-- 02. REFERENTIAL INTEGRITY CHECK – PRODUCT KEY
-- ================================================================================================

/*
    Objective:
    Verify that every product in the sales table exists in the Product dimension table.
*/

SELECT DISTINCT SLS_PRD_KEY
FROM [Bronze].[Crm_SalesDetails]
WHERE sls_prd_key NOT IN (SELECT PRD_KEY FROM Silver.Crm_PrdInfo)


-- ================================================================================================
-- 03. REFERENTIAL INTEGRITY CHECK – CUSTOMER ID
-- ================================================================================================

/*
    Objective:
    Verify that every customer referenced in sales exists in the Customer dimension table.
*/

SELECT DISTINCT sls_cust_id
FROM [Bronze].[Crm_SalesDetails]
WHERE sls_prd_key NOT IN (SELECT CST_ID FROM Silver.Crm_CustInfo)


-- ================================================================================================
-- 04. DATE VALIDATION – ORDER DATE
-- ================================================================================================

/*
    Objective:
    Validate order date values.

    Observed Issues:
    - Dates stored as integers (YYYYMMDD)
    - Invalid length
    - Zero values
    - Unrealistic dates

    Cleaning Strategy:
    Replace invalid values with NULL.
*/

SELECT DISTINCT NULLIF(SLS_ORDER_DT,0)
FROM [Bronze].[Crm_SalesDetails]
WHERE 
LEN(SLS_ORDER_DT) != 8
OR sls_order_dt = 0 
OR sls_order_dt <= 19000101

-- Convert valid integer dates to DATE datatype

SELECT
CASE
    WHEN LEN(SLS_ORDER_DT) != 8 
         OR sls_order_dt = 0 
         OR sls_order_dt <= 19000101 
         OR sls_order_dt >= 20500101
    THEN NULL
    ELSE CAST(CAST(SLS_ORDER_DT AS NVARCHAR) AS DATE)
END AS SLS_ORDER_DT_NEW
FROM [Bronze].[Crm_SalesDetails]


-- ================================================================================================
-- 05. DATE VALIDATION – SHIPPING DATE
-- ================================================================================================

/*
    Objective:
    Clean shipping date values using the same validation rules.
*/

SELECT DISTINCT NULLIF(SLS_SHIP_DT,0)
FROM [Bronze].[Crm_SalesDetails]
WHERE 
LEN(SLS_SHIP_DT) != 8
OR SLS_SHIP_DT = 0 
OR SLS_SHIP_DT <= 19000101


SELECT
CASE
    WHEN LEN(SLS_SHIP_DT) != 8 
         OR SLS_SHIP_DT = 0 
         OR SLS_SHIP_DT <= 19000101 
         OR SLS_SHIP_DT >= 20500101
    THEN NULL
    ELSE CAST(CAST(SLS_SHIP_DT AS NVARCHAR) AS DATE)
END AS SLS_SHIP_DT_NEW
FROM [Bronze].[Crm_SalesDetails]


-- ================================================================================================
-- 06. DATE VALIDATION – DUE DATE
-- ================================================================================================

/*
    Objective:
    Clean due date values using the same validation rules.
*/

SELECT DISTINCT NULLIF(SLS_DUE_DT,0)
FROM [Bronze].[Crm_SalesDetails]
WHERE 
LEN(SLS_DUE_DT) != 8
OR SLS_DUE_DT = 0 
OR SLS_DUE_DT <= 19000101


SELECT
CASE
    WHEN LEN(SLS_DUE_DT) != 8 
         OR SLS_DUE_DT = 0 
         OR SLS_DUE_DT <= 19000101 
         OR SLS_DUE_DT >= 20500101
    THEN NULL
    ELSE CAST(CAST(SLS_DUE_DT AS NVARCHAR) AS DATE)
END AS SLS_DUE_DT_NEW
FROM [Bronze].[Crm_SalesDetails]


-- ================================================================================================
-- 07. SALES DATA CONSISTENCY CHECK
-- ================================================================================================

/*
    Objective:
    Validate relationship between sales, quantity, and price.

    Expected Formula:
        Sales = Quantity × Price

    Issues Identified:
    - Incorrect calculations
    - NULL values
    - Negative values
*/

SELECT DISTINCT
    sls_sales, sls_quantity, sls_price
FROM [Bronze].[Crm_SalesDetails]
WHERE 
    (sls_sales != sls_quantity * sls_price)
    OR sls_sales IS NULL 
    OR sls_quantity IS NULL 
    OR sls_price IS NULL
    OR sls_sales < 0 
    OR sls_quantity < 0 
    OR sls_price < 0


/*
    Data Correction Strategy:

    1. If sales is NULL, negative, or incorrect → derive using quantity × price
    2. If price is NULL or zero → derive using sales / quantity
    3. If price is negative → convert to positive
*/

SELECT 
CASE 
    WHEN sls_sales IS NULL 
         OR sls_sales <= 0 
         OR sls_sales != sls_quantity * ABS(sls_price)
    THEN sls_quantity * ABS(sls_price)
    ELSE sls_sales
END AS sls_sales,

CASE 
    WHEN sls_price IS NULL 
         OR sls_sales <= 0
    THEN sls_sales / NULLIF(sls_quantity,0)
    ELSE sls_price
END AS sls_price

FROM [Bronze].[Crm_SalesDetails]


-- ================================================================================================
-- FINAL CLEANED DATASET VALIDATION
-- ================================================================================================

/*
    Objective:
    Generate cleaned dataset and identify logical date inconsistencies.

    Checks performed:
    - Clean order date
    - Clean ship date
    - Clean due date
    - Validate logical sequence:
        Order Date ≤ Ship Date ≤ Due Date
*/
*/
;with Sales_Table as
(
SELECT
    sls_ord_num, 
    sls_prd_key, 
    sls_cust_id, 

    CASE
        WHEN LEN(SLS_ORDER_DT) != 8 
             OR sls_order_dt = 0 
        THEN NULL
        ELSE CAST(CAST(SLS_ORDER_DT AS NVARCHAR) AS DATE)
    END AS SLS_ORDER_DT, 

    CASE
        WHEN LEN(SLS_SHIP_DT) != 8 
             OR SLS_SHIP_DT = 0 
        THEN NULL
        ELSE CAST(CAST(SLS_SHIP_DT AS NVARCHAR) AS DATE)
    END AS SLS_SHIP_DT, 

    CASE
        WHEN LEN(SLS_DUE_DT) != 8 
             OR SLS_DUE_DT = 0 
        THEN NULL
        ELSE CAST(CAST(SLS_DUE_DT AS NVARCHAR) AS DATE)
    END AS SLS_DUE_DT, 

	CASE 
		WHEN sls_sales IS NULL 
			 OR sls_sales <= 0 
			 OR sls_sales != sls_quantity * ABS(sls_price)
		THEN sls_quantity * ABS(sls_price)
		ELSE sls_sales
	END AS sls_sales,
	sls_quantity,
	CASE 
		WHEN sls_price IS NULL 
			 OR sls_sales <= 0
		THEN sls_sales / NULLIF(sls_quantity,0)
		ELSE sls_price
	END AS sls_price


FROM [Bronze].[Crm_SalesDetails]
)

INSERT INTO Silver.Crm_SalesDetails
(sls_ord_num, sls_prd_key, sls_cust_id, 
sls_order_dt, sls_ship_dt, sls_due_dt, sls_sales, sls_quantity, sls_price)

select sls_ord_num, sls_prd_key, sls_cust_id, 
sls_order_dt, sls_ship_dt, sls_due_dt , sls_sales, sls_quantity, sls_price
from Sales_Table 
--where SLS_ORDER_DT > SLS_SHIP_DT or SLS_ORDER_DT > SLS_DUE_DT

--TRUNCATE TABLE Silver.Crm_SalesDetails
--SELECT * FROM Silver.Crm_SalesDetails