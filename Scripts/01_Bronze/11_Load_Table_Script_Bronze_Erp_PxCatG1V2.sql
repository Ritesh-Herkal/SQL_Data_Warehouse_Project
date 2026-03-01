USE DataWareHouse
GO

/*
Developer		 : Ritesh Herkal
Developed on	 : 01-March-2026
				 
Script Purpose	 : Script to Load data to table Erp_PxCatG1V2
Script Objective : This script would be truncating the existing data in Bronze.Erp_PxCatG1V2 and loading it with data from its source file PX_CAT_G1V2
How to Execute	 : This script will be run as and when required. We can select the whole code an click on Execute.

Revision History:
Developed By		Developed On			Description
Ritesh Herkal		01-March-2026			Initial Draft

*/

TRUNCATE TABLE Bronze.Erp_PxCatG1V2;
GO

BULK INSERT Bronze.Erp_PxCatG1V2
FROM 'C:\Users\rites\Downloads\Data WareHouse Project\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
WITH
(
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
)

SELECT COUNT(*) FROM Bronze.Erp_PxCatG1V2
SELECT * FROM Bronze.Erp_PxCatG1V2