SELECT * FROM Bronze.Erp_CustAZ12
--18483
--==================================

SELECT DISTINCT GEN
FROM
Bronze.Erp_CustAZ12

/*
GEN
NULL
F 
  
Male
Female
M 
*/
SELECT DISTINCT * FROM (
SELECT
GEN,
CASE
	WHEN UPPER(TRIM(GEN)) IN ('M', 'MALE') THEN 'Male'
	WHEN UPPER(TRIM(GEN)) IN ('F', 'FEMALE') THEN 'Female'
	ELSE 'N/A'
END
AS GEN_NEW
FROM
Bronze.Erp_CustAZ12
) A

--=======================================================

SELECT BDATE 
FROM
Bronze.Erp_CustAZ12
WHERE BDATE>GETDATE()
--WHERE CAST(BDATE AS date) != BDATE


SELECT 
CASE 
	WHEN BDATE > GETDATE() THEN NULL
	ELSE BDATE
END AS BDATE
FROM
Bronze.Erp_CustAZ12

--=======================================================

SELECT DISTINCT CID 
FROM
Bronze.Erp_CustAZ12
--18483

SELECT
CASE
	WHEN CID LIKE 'NAS%' THEN SUBSTRING(CID,4,LEN(CID))
	ELSE CID
END AS CID
FROM
Bronze.Erp_CustAZ12

--===================================================

--FINAL QUERY

SELECT 
CASE
	WHEN CID LIKE 'NAS%' THEN SUBSTRING(CID,4,LEN(CID))
	ELSE CID
END AS CID,
CASE 
	WHEN BDATE > GETDATE() THEN NULL
	ELSE BDATE
END AS BDATE,
CASE
	WHEN UPPER(TRIM(GEN)) IN ('M', 'MALE') THEN 'Male'
	WHEN UPPER(TRIM(GEN)) IN ('F', 'FEMALE') THEN 'Female'
	ELSE 'N/A'
END
AS GEN
FROM
Bronze.Erp_CustAZ12