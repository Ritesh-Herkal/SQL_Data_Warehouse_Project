SELECT * FROM [Bronze].[Crm_SalesDetails]
--60398

--=============================================

SELECT DISTINCT SLS_ORD_NUM 
FROM [Bronze].[Crm_SalesDetails] --27659
--THAT MEANS WE HAVE DUPLICATES

SELECT  * --SLS_ORD_NUM 
FROM [Bronze].[Crm_SalesDetails] 
WHERE SLS_ORD_NUM IN ('SO51176','SO51177','SO51178')
ORDER BY 1


SELECT SLS_ORD_NUM,COUNT(1), sls_prd_key
FROM [Bronze].[Crm_SalesDetails]
GROUP BY sls_ord_num, sls_prd_key
HAVING COUNT(1)>1
ORDER BY 1
--SO51176
--SO51177
--SO51178

--SO THE B.KEY IS A COMBINATION OF SLS_ORD_NUM AND SLS_PRD_KEY

--=============================================

SELECT DISTINCT SLS_PRD_KEY
FROM [Bronze].[Crm_SalesDetails]
WHERE sls_prd_key NOT IN (SELECT PRD_KEY FROM Silver.Crm_PrdInfo)

SELECT DISTINCT sls_cust_id
FROM [Bronze].[Crm_SalesDetails]
WHERE sls_prd_key NOT IN (SELECT CST_ID FROM Silver.Crm_CustInfo)

--=============================================

SELECT DISTINCT NULLIF(SLS_ORDER_DT,0)
FROM [Bronze].[Crm_SalesDetails]
WHERE LEN(SLS_ORDER_DT) !=8
OR sls_order_dt = 0 
OR sls_order_dt <= 19000101
--WE HAVE 0 SO REPLACE IT WITH NULLS

SELECT
CASE
	WHEN LEN(SLS_ORDER_DT) !=8 OR sls_order_dt = 0 OR sls_order_dt <= 19000101 OR sls_order_dt >=20500101
	THEN NULL
	ELSE
	CAST(CAST(SLS_ORDER_DT AS NVARCHAR) AS DATE)
END AS SLS_ORDER_DT_NEW
FROM [Bronze].[Crm_SalesDetails]



--=============================================

SELECT DISTINCT NULLIF(SLS_SHIP_DT,0)
FROM [Bronze].[Crm_SalesDetails]
WHERE LEN(SLS_SHIP_DT) !=8
OR SLS_SHIP_DT = 0 
OR SLS_SHIP_DT <= 19000101
--WE HAVE 0 SO REPLACE IT WITH NULLS

SELECT
CASE
	WHEN LEN(SLS_SHIP_DT) !=8 OR SLS_SHIP_DT = 0 OR SLS_SHIP_DT <= 19000101 OR SLS_SHIP_DT >=20500101
	THEN NULL
	ELSE
	CAST(CAST(SLS_SHIP_DT AS NVARCHAR) AS DATE)
END AS SLS_SHIP_DT_NEW
FROM [Bronze].[Crm_SalesDetails]


--=============================================

SELECT DISTINCT NULLIF(SLS_DUE_DT,0)
FROM [Bronze].[Crm_SalesDetails]
WHERE LEN(SLS_DUE_DT) !=8
OR SLS_DUE_DT = 0 
OR SLS_DUE_DT <= 19000101
--WE HAVE 0 SO REPLACE IT WITH NULLS

SELECT
CASE
	WHEN LEN(SLS_DUE_DT) !=8 OR SLS_DUE_DT = 0 OR SLS_DUE_DT <= 19000101 OR SLS_DUE_DT >=20500101
	THEN NULL
	ELSE
	CAST(CAST(SLS_DUE_DT AS NVARCHAR) AS DATE)
END AS SLS_DUE_DT_NEW
FROM [Bronze].[Crm_SalesDetails]

--=====================================================

SELECT DISTINCT
sls_sales, sls_quantity, sls_price
FROM 
[Bronze].[Crm_SalesDetails]
WHERE 
(sls_sales != sls_quantity * sls_price)
OR
sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR
sls_sales <0 OR sls_quantity <0 OR sls_price <0

-- TO FIX THIS BAD DATA,
--WE CAN
--IF SLS_SALES IS NEGATIVE, 0 OR NULL, DERIVEW IT FRMO SLS_QUANTITY * SLS_PRICE
--IF SLS_PRICE IS 0 OR NULL, DERIEVEW IT FROM  SALES/QUANTITY
--IF SLS_PRICE IS NEGATIVE , CONVERT TO POSITIVE


SELECT 
CASE 
	WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
	THEN sls_quantity * ABS(sls_price)
	ELSE sls_sales
END AS sls_sales,
CASE 
	WHEN sls_price IS NULL OR sls_sales <= 0
	THEN  sls_sales / NULLIF(sls_quantity,0)
	ELSE sls_PRICE
END AS sls_price,


FROM 
[Bronze].[Crm_SalesDetails]

--==========================================================

-- FINAL SELECT --

;
WITH CTE_A AS
(
SELECT
sls_ord_num, sls_prd_key, sls_cust_id, 
CASE
	WHEN LEN(SLS_ORDER_DT) !=8 OR sls_order_dt = 0 OR sls_order_dt <= 19000101 OR sls_order_dt >=20500101
	THEN NULL
	ELSE
	CAST(CAST(SLS_ORDER_DT AS NVARCHAR) AS DATE)
END AS SLS_ORDER_DT, 
CASE
	WHEN LEN(SLS_SHIP_DT) !=8 OR SLS_SHIP_DT = 0 OR SLS_SHIP_DT <= 19000101 OR SLS_SHIP_DT >=20500101
	THEN NULL
	ELSE
	CAST(CAST(SLS_SHIP_DT AS NVARCHAR) AS DATE)
END AS SLS_SHIP_DT, 
CASE
	WHEN LEN(SLS_DUE_DT) !=8 OR SLS_DUE_DT = 0 OR SLS_DUE_DT <= 19000101 OR SLS_DUE_DT >=20500101
	THEN NULL
	ELSE
	CAST(CAST(SLS_DUE_DT AS NVARCHAR) AS DATE)
END AS SLS_DUE_DT, 
sls_sales, sls_quantity, sls_price
FROM [Bronze].[Crm_SalesDetails] 
)

SELECT * FROM CTE_A
WHERE SLS_ORDER_DT>SLS_SHIP_DT OR SLS_ORDER_DT>SLS_DUE_DT 