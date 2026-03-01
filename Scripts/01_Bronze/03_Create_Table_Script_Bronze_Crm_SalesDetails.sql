USE DataWareHouse
GO

/*
Developer		 : Ritesh Herkal
Developed on	 : 01-March-2026
				 
Script Purpose	 : Creation of table Crm_SalesDetails
Script Objective : To store Data coming from one the CRM source Files, sales_details
How to Execute	 : Select * from Bronze.Crm_SalesDetails

Revision History:
Developed By		Developed On			Description
Ritesh Herkal		01-March-2026			Initial Draft

*/

-- Step 1: Check if table exists
IF OBJECT_ID('Bronze.Crm_SalesDetails', 'U') IS NOT NULL
BEGIN
    PRINT 'Table exists. Creating backup...';

    -- Step 2: Declare variables
    DECLARE @SchemaName NVARCHAR(100)		= 'Bronze'
    DECLARE @TableName NVARCHAR(100)		= 'Crm_SalesDetails'
    DECLARE @BackupTableName NVARCHAR(200)
    DECLARE @SQL NVARCHAR(MAX)

    -- Step 3: Generate backup table name with today’s date
    SET @BackupTableName = @TableName + '_Backup_' + FORMAT(GETDATE(), 'yyyyMMdd')

    -- Step 4: Create backup table using dynamic SQL
    SET @SQL = 'SELECT * INTO ' +  QUOTENAME(@SchemaName) + '.' +  QUOTENAME(@BackupTableName) + ' FROM ' +  QUOTENAME(@SchemaName) + '.' +  QUOTENAME(@TableName)

    EXEC sp_executesql @SQL

    PRINT 'Backup created: ' + @BackupTableName;

    -- Step 5: Drop original table using dynamic SQL
    SET @SQL =  'DROP TABLE ' +  QUOTENAME(@SchemaName) + '.' +  QUOTENAME(@TableName)

    EXEC sp_executesql @SQL

    PRINT 'Old table dropped.';
END

--Step 6 : Creates the Table
CREATE TABLE Bronze.Crm_SalesDetails
(
	sls_ord_num				NVARCHAR(50),
	sls_prd_key				NVARCHAR(50),
	sls_cust_id				INT,
	sls_order_dt			INT,
	sls_ship_dt				INT,
	sls_due_dt				INT,
	sls_sales				INT,
	sls_quantity			INT,
	sls_price				INT
);
GO


