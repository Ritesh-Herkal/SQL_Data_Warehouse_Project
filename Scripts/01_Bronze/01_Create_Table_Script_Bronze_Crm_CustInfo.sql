USE DataWareHouse
GO

/*
Developer		 : Ritesh Herkal
Developed on	 : 01-March-2026
				 
Script Purpose	 : Creation of table Crm_CustInfo
Script Objective : To store Data coming from one the CRM source Files, custInfo
How to Execute	 : Select * from Bronze.Crm_CustInfo

Revision History:
Developed By		Developed On			Description
Ritesh Herkal		01-March-2026			Initial Draft

*/


-- Step 1: Check if table exists
IF OBJECT_ID('Bronze.Crm_CustInfo', 'U') IS NOT NULL
BEGIN
    PRINT 'Table exists. Creating backup...';

    -- Step 2: Declare variables
    DECLARE @SchemaName NVARCHAR(100)		= 'Bronze'
    DECLARE @TableName NVARCHAR(100)		= 'Crm_CustInfo'
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
CREATE TABLE Bronze.Crm_CustInfo
(
	cst_id				INT,
	cst_key				NVARCHAR(50),
	cst_firstname		NVARCHAR(100),
	cst_lastname		NVARCHAR(100),
	cst_marital_status	NVARCHAR(10),
	cst_gndr			NVARCHAR(10),
	cst_create_date		DATE
);
GO
