USE DataWareHouse
GO

/*
Developer		 : Ritesh Herkal
Developed on	 : 01-March-2026
				 
Script Purpose	 : Script to Load data to table Crm_PrdInfo
Script Objective : This script would be truncating the existing data in Bronze.Crm_PrdInfo and loading it with data from its source file prd_Info
How to Execute	 : This script will be run as and when required. We can select the whole code an click on Execute.

Revision History:
Developed By		Developed On			Description
Ritesh Herkal		01-March-2026			Initial Draft

*/

TRUNCATE TABLE Bronze.Crm_PrdInfo;
GO

BULK INSERT Bronze.Crm_PrdInfo
FROM 'C:\Users\rites\Downloads\Data WareHouse Project\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
WITH
(
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
)

SELECT COUNT(*) FROM Bronze.Crm_PrdInfo
SELECT * FROM Bronze.Crm_PrdInfo