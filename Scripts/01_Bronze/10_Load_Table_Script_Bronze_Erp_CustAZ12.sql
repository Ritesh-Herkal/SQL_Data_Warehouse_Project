USE DataWareHouse
GO

/*
Developer		 : Ritesh Herkal
Developed on	 : 01-March-2026
				 
Script Purpose	 : Script to Load data to table Erp_CustAZ12
Script Objective : This script would be truncating the existing data in Bronze.Erp_CustAZ12 and loading it with data from its source file Cust_AZ12
How to Execute	 : This script will be run as and when required. We can select the whole code an click on Execute.

Revision History:
Developed By		Developed On			Description
Ritesh Herkal		01-March-2026			Initial Draft

*/

TRUNCATE TABLE Bronze.Erp_CustAZ12;
GO

BULK INSERT Bronze.Erp_CustAZ12
FROM 'C:\Users\rites\Downloads\Data WareHouse Project\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
WITH
(
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
)

SELECT COUNT(*) FROM Bronze.Erp_CustAZ12
SELECT * FROM Bronze.Erp_CustAZ12