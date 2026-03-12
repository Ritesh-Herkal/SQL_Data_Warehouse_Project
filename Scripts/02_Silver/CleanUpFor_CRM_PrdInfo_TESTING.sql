 USE DataWareHouse
GO

SELECT * FROM Bronze.Crm_PrdInfo
--397 



------------------------------------------------------------------
--01: prd_id is a key column with valid data no problem
SELECT DISTINCT PRD_ID FROM Bronze.Crm_PrdInfo
WHERE prd_id IS NOT NULL
------------------------------------------------------------------
--02 : prd_key can split into 2 different column, first 5 chars can be category value, we came to this decision by looking data in table erp.Erp_PxCatG1V2
--CAN VERIFY NEW_PRD_KEY WITH SALES TABLE SLS_PRD_KEY --SELECT * FROM Bronze.Crm_SalesDetails

SELECT
REPLACE(SUBSTRING(prd_key,1,5),'-','_') AS Cat_ID,
prd_key,
SUBSTRING(prd_key,7,LEN(prd_key)) as prd_key_new
FROM Bronze.Crm_PrdInfo
------------------------------------------------------------------

--03 : PRD_COST, WE CAN REPLACE NULL WITH 0

SELECT
prd_cost,
ISNULL(prd_cost,0) AS NEW_PRD_COST
FROM Bronze.Crm_PrdInfo
------------------------------------------------------------------

--04 : Check date columns
--END DATE LESS THAN START DATE

SELECT 
*
,DATEADD(DAY,-1,LEAD(prd_start_dt) OVER (PARTITION BY PRD_KEY ORDER BY PRD_START_DT))  AS NEW_END_DATE
FROM Bronze.Crm_PrdInfo
where prd_start_dt >  prd_end_dt 
ORDER BY prd_key, prd_end_dt


-- ================================================================================================
-- FINAL CLEANED DATASET (READY FOR SILVER LAYER)
-- ================================================================================================


SELECT * FROM Bronze.Crm_PrdInfo

--REPLACE(SUBSTRING(prd_key,1,5),'-','_') AS Cat_ID,
--SUBSTRING(prd_key,7,LEN(prd_key)) as prd_key

--ISNULL(prd_cost,0) AS prd_cost
--,DATEADD(DAY,-1,LEAD(prd_start_dt) OVER (PARTITION BY PRD_KEY ORDER BY PRD_START_DT))  AS NEW_END_DATE

SELECT
prd_id,
REPLACE(SUBSTRING(prd_key,1,5),'-','_') AS Cat_ID,
SUBSTRING(prd_key,7,LEN(prd_key)) as prd_key,
prd_nm,
ISNULL(prd_cost,0) AS prd_cost,
prd_line,
prd_start_dt,
DATEADD(DAY,-1,LEAD(prd_start_dt) OVER (PARTITION BY PRD_KEY ORDER BY PRD_START_DT))  AS prd_end_dt
FROM Bronze.Crm_PrdInfo
order by 2,3 