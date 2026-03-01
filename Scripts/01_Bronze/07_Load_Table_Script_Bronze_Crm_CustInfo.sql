USE DataWareHouse
GO

/*
Developer		 : Ritesh Herkal
Developed on	 : 01-March-2026
				 
Script Purpose	 : Script to Load data to table Crm_CustInfo
Script Objective : This script would be truncating the existing data in Bronze.Crm_CustInfo and loading it with data from its source file custInfo
How to Execute	 : This script will be run as and when required. We can select the whole code an click on Execute.

Revision History:
Developed By		Developed On			Description
Ritesh Herkal		01-March-2026			Initial Draft

*/

TRUNCATE TABLE Bronze.Crm_CustInfo;
GO

BULK INSERT Bronze.Crm_CustInfo
FROM 'C:\Users\rites\Downloads\Data WareHouse Project\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
WITH
(
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
)

SELECT COUNT(*) FROM Bronze.Crm_CustInfo
SELECT * FROM Bronze.Crm_CustInfo