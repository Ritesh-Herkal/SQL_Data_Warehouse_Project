USE DataWareHouse
GO

/**************************************************************************************************
    TABLE        : Bronze.Erp_CustAZ12
    PURPOSE      : Data Quality Checks & Cleaning for ERP Customer Demographic Data
    TOTAL ROWS   : 18,483
**************************************************************************************************/

SELECT * FROM Bronze.Erp_CustAZ12


-- ================================================================================================
-- 01. DATA CONSISTENCY CHECK – GENDER COLUMN (GEN)
-- ================================================================================================

/*
    Objective:
    Standardize gender values.

    Observed Issues:
    - Multiple formats used for gender
    - Extra spaces
    - Mixed case values
    - NULL or blank values

    Example values found:
        NULL
        F
        M
        Male
        Female
        (blank)

    Cleaning Strategy:
    - Remove leading/trailing spaces using TRIM()
    - Convert to uppercase using UPPER()
    - Map abbreviations to full values
    - Replace unknown values with 'N/A'
*/

SELECT DISTINCT GEN
FROM Bronze.Erp_CustAZ12


-- Preview transformation
SELECT DISTINCT * 
FROM
(
    SELECT
        GEN,
        CASE
            WHEN UPPER(TRIM(GEN)) IN ('M','MALE') THEN 'Male'
            WHEN UPPER(TRIM(GEN)) IN ('F','FEMALE') THEN 'Female'
            ELSE 'N/A'
        END AS GEN_NEW
    FROM Bronze.Erp_CustAZ12
) A


-- ================================================================================================
-- 02. DATE VALIDATION – BIRTH DATE (BDATE)
-- ================================================================================================

/*
    Objective:
    Ensure that birth dates are valid.

    Issue Identified:
    - Some records contain future dates which are not logically valid.

    Cleaning Strategy:
    - Replace future dates with NULL
*/

SELECT BDATE
FROM Bronze.Erp_CustAZ12
WHERE BDATE > GETDATE()


-- Preview transformation
SELECT 
CASE 
    WHEN BDATE > GETDATE() THEN NULL
    ELSE BDATE
END AS BDATE
FROM Bronze.Erp_CustAZ12


-- ================================================================================================
-- 03. CUSTOMER ID STANDARDIZATION – CID
-- ================================================================================================

/*
    Objective:
    Standardize customer IDs.

    Observed Issue:
    Some customer IDs contain a prefix 'NAS'.

    Example:
        NAS12345 → 12345

    Cleaning Strategy:
    - Remove 'NAS' prefix using SUBSTRING()
*/

SELECT DISTINCT CID
FROM Bronze.Erp_CustAZ12


-- Preview transformation
SELECT
CASE
    WHEN CID LIKE 'NAS%' THEN SUBSTRING(CID,4,LEN(CID))
    ELSE CID
END AS CID
FROM Bronze.Erp_CustAZ12


-- ================================================================================================
-- FINAL CLEANED DATASET (READY FOR SILVER LAYER)
-- ================================================================================================

/*
    Transformations Applied:

    1. Remove 'NAS' prefix from customer IDs
    2. Replace future birth dates with NULL
    3. Standardize gender values
*/

INSERT INTO Silver.Erp_CustAZ12
(CID, BDATE,GEN)
SELECT 

-- Clean Customer ID
CASE
    WHEN CID LIKE 'NAS%' THEN SUBSTRING(CID,4,LEN(CID))
    ELSE CID
END AS CID,

-- Validate Birth Date
CASE 
    WHEN BDATE > GETDATE() THEN NULL
    ELSE BDATE
END AS BDATE,

-- Standardize Gender
CASE
    WHEN UPPER(TRIM(GEN)) IN ('M','MALE') THEN 'Male'
    WHEN UPPER(TRIM(GEN)) IN ('F','FEMALE') THEN 'Female'
    ELSE 'N/A'
END AS GEN

FROM Bronze.Erp_CustAZ12
