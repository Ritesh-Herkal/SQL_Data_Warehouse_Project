USE DataWareHouse
GO

/**************************************************************************************************
    TABLE        : Bronze.Crm_PrdInfo
    PURPOSE      : Data Quality Checks & Cleaning for Product Information
    TOTAL ROWS   : 397
**************************************************************************************************/

SELECT * FROM Bronze.Crm_PrdInfo

-- ================================================================================================
-- 01. VALIDATE PRIMARY KEY COLUMN (prd_id)
-- ================================================================================================

/*
    Objective:
    Verify that prd_id behaves like a primary key and contains valid values.

    Approach:
    - Check for NULL values
    - Verify uniqueness
*/

SELECT DISTINCT PRD_ID
FROM Bronze.Crm_PrdInfo
WHERE prd_id IS NOT NULL


-- ================================================================================================
-- 02. SPLIT prd_key INTO CATEGORY AND PRODUCT KEY
-- ================================================================================================

/*
    Objective:
    Extract category identifier and product identifier from prd_key.

    Observations:
    - First 5 characters represent category code
    - Remaining characters represent product key
    - Category codes match values in table: erp.Erp_PxCatG1V2

    Example:
        prd_key = CO-PR_001
        Category = CO_PR
        Product Key = 001

    Verification:
    - New product key can be cross checked with sales table:
      Bronze.Crm_SalesDetails (column: sls_prd_key)
*/

SELECT
    REPLACE(SUBSTRING(prd_key,1,5),'-','_') AS Cat_ID,
    prd_key,
    SUBSTRING(prd_key,7,LEN(prd_key)) AS prd_key_new
FROM Bronze.Crm_PrdInfo


-- ================================================================================================
-- 03. HANDLE NULL VALUES IN PRODUCT COST
-- ================================================================================================

/*
    Objective:
    Replace NULL product cost values with 0.

    Reason:
    - Cost should not remain NULL
    - Helps avoid aggregation and calculation errors
*/

SELECT
    prd_cost,
    ISNULL(prd_cost,0) AS NEW_PRD_COST
FROM Bronze.Crm_PrdInfo


-- ================================================================================================
-- 04. DATE VALIDATION CHECK – PRODUCT START AND END DATE
-- ================================================================================================

/*
    Objective:
    Identify records where end date is earlier than start date.

    Issue:
    Some records contain invalid ranges:
        prd_start_dt > prd_end_dt

    Solution:
    - Use LEAD() to fetch the next product start date
    - Set the current record's end date as:
        next_start_date - 1 day
*/

SELECT 
    *,
    DATEADD(DAY,-1,
        LEAD(prd_start_dt) OVER
        (
            PARTITION BY PRD_KEY 
            ORDER BY PRD_START_DT
        )
    ) AS NEW_END_DATE
FROM Bronze.Crm_PrdInfo
WHERE prd_start_dt > prd_end_dt
ORDER BY prd_key, prd_end_dt


-- ================================================================================================
-- FINAL CLEANED DATASET (READY FOR SILVER LAYER)
-- ================================================================================================

/*
    Transformations Applied:

    1. Extract category ID from prd_key
    2. Extract clean product key
    3. Replace NULL product cost with 0
    4. Correct product end date using next start date logic
*/

SELECT
    prd_id,

    -- Extract category identifier
    REPLACE(SUBSTRING(prd_key,1,5),'-','_') AS Cat_ID,

    -- Extract product key
    SUBSTRING(prd_key,7,LEN(prd_key)) AS prd_key,

    prd_nm,

    -- Replace NULL cost values
    ISNULL(prd_cost,0) AS prd_cost,

    prd_line,

    prd_start_dt,

    -- Generate corrected end date
    DATEADD(DAY,-1,
        LEAD(prd_start_dt) OVER
        (
            PARTITION BY PRD_KEY 
            ORDER BY PRD_START_DT
        )
    ) AS prd_end_dt

FROM Bronze.Crm_PrdInfo
