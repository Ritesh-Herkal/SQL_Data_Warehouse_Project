USE DataWareHouse
GO

/*
Developer		 : Ritesh Herkal
Developed on	 : 01-March-2026
				 
Script Purpose	 : Creation of table Erp_PxCatG1V2
Script Objective : To store Data coming from one the Erp source Files, PX_CAT_G1V2
How to Execute	 : Select * from Bronze.Erp_PxCatG1V2

Revision History:
Developed By		Developed On			Description
Ritesh Herkal		01-March-2026			Initial Draft

*/

-- Step 1: Check if table exists
IF OBJECT_ID('Bronze.Erp_PxCatG1V2', 'U') IS NOT NULL
BEGIN
    PRINT 'Table exists. Creating backup...';

    -- Step 2: Declare variables
    DECLARE @SchemaName NVARCHAR(100)		= 'Bronze'
    DECLARE @TableName NVARCHAR(100)		= 'Erp_PxCatG1V2'
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
CREATE TABLE Bronze.Erp_PxCatG1V2
(
	ID				NVARCHAR(50),
	CAT				NVARCHAR(50),
	SUBCAT			NVARCHAR(100),
	MAINTENANCE		NVARCHAR(10)
);
GO


