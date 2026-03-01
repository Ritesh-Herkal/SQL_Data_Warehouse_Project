USE DataWareHouse
GO

/*
Developer		 : Ritesh Herkal
Developed on	 : 01-March-2026
				 
Script Purpose	 : Load data from Source System (CRM & ERP) into Bronze Layer
Script Objective :	1. Truncate existing Bronze tables
					2. Bulk load fresh data from CSV files
					3. Capture load duration
					4. Handle and report errors properly

How to Execute	 : EXEC Bronze.Load_Bronze

Revision History:
Developed By		Developed On			Description
Ritesh Herkal		01-March-2026			Initial Draft

*/

CREATE OR ALTER PROCEDURE Bronze.Load_Bronze 
AS

BEGIN
	---------------------------------------------------------------------------
    -- Prevents extra "(x rows affected)" messages
    ---------------------------------------------------------------------------
    SET NOCOUNT ON;
	
	---------------------------------------------------------------------------
    -- Variable Declaration for Tracking Execution Time
    ---------------------------------------------------------------------------
	DECLARE @START_TIME DATETIME, @END_TIME DATETIME
	DECLARE @BATCH_START_TIME DATETIME, @BATCH_END_TIME DATETIME


	BEGIN TRY
		-----------------------------------------------------------------------
        -- Capture Batch Start Time
        -----------------------------------------------------------------------
		SET @BATCH_START_TIME = GETDATE();
		
		PRINT '-----------------------------------------------------------------------------------------------------------------------';
		PRINT 'LOADING BRONZE LAYER...';
		PRINT '-----------------------------------------------------------------------------------------------------------------------';

		PRINT '-----------------------------------------------------------------------------------------------------------------------';
		PRINT 'Loading CRM Tables...';
		PRINT '-----------------------------------------------------------------------------------------------------------------------';

		-----------------------------------------------------------------------
		--Used for Testing Catch Block
		--THROW 50001, 'Manual Test Error for Catch Block', 1;
		-----------------------------------------------------------------------

		-----------------------------------------------------------------------
        -- CRM - Customer Info
        -----------------------------------------------------------------------

		SET @START_TIME = GETDATE(); 
		PRINT '>> Truncating Table		: [Bronze].[Crm_CustInfo]';
		TRUNCATE TABLE Bronze.Crm_CustInfo;

		PRINT '>> Inserting Data Into	: [Bronze].[Crm_CustInfo]';
		BULK INSERT Bronze.Crm_CustInfo
		FROM 'C:\Users\rites\Downloads\Data WareHouse Project\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		
		WITH
		(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		)
		SET @END_TIME = GETDATE()
		PRINT'>> LOAD DURATION : ' + CAST(DATEDIFF(SECOND,@START_TIME,@END_TIME) AS NVARCHAR) + ' seconds.'
		PRINT '-----------------------------------------'


		-----------------------------------------------------------------------
        -- CRM - Product Info
        -----------------------------------------------------------------------

		SET @START_TIME = GETDATE(); 
		PRINT '>> Truncating Table		: [Bronze].[Crm_PrdInfo]';
		TRUNCATE TABLE Bronze.Crm_PrdInfo;

		PRINT '>> Inserting Data Into	: [Bronze].[Crm_PrdInfo]';
		BULK INSERT Bronze.Crm_PrdInfo
		FROM 'C:\Users\rites\Downloads\Data WareHouse Project\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		WITH
		(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		)
		SET @END_TIME = GETDATE()
		PRINT'>> LOAD DURATION : ' + CAST(DATEDIFF(SECOND,@START_TIME,@END_TIME) AS NVARCHAR) + ' seconds.'
		PRINT '-----------------------------------------'

		-----------------------------------------------------------------------
        -- CRM - Sales Details
        -----------------------------------------------------------------------

		SET @START_TIME = GETDATE(); 
		PRINT '>> Truncating Table		: [Bronze].[Crm_SalesDetails]';
		TRUNCATE TABLE Bronze.Crm_SalesDetails;

		PRINT '>> Inserting Data Into	: [Bronze].[Crm_SalesDetails]';
		BULK INSERT Bronze.Crm_SalesDetails
		FROM 'C:\Users\rites\Downloads\Data WareHouse Project\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		WITH
		(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		)
		SET @END_TIME = GETDATE()
		PRINT'>> LOAD DURATION : ' + CAST(DATEDIFF(SECOND,@START_TIME,@END_TIME) AS NVARCHAR) + ' seconds.'
		PRINT '-----------------------------------------'

		PRINT '-----------------------------------------------------------------------------------------------------------------------';
		PRINT 'Loading ERP Tables...';
		PRINT '-----------------------------------------------------------------------------------------------------------------------';

		-----------------------------------------------------------------------
        -- ERP - Customer
        -----------------------------------------------------------------------

		SET @START_TIME = GETDATE(); 
		PRINT '>> Truncating Table		: [Bronze].[Erp_CustAZ12]';
		TRUNCATE TABLE Bronze.Erp_CustAZ12;

		PRINT '>> Inserting Data Into	: [Bronze].[Erp_CustAZ12]';
		BULK INSERT Bronze.Erp_CustAZ12
		FROM 'C:\Users\rites\Downloads\Data WareHouse Project\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
		WITH
		(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		)
		SET @END_TIME = GETDATE()
		PRINT'>> LOAD DURATION : ' + CAST(DATEDIFF(SECOND,@START_TIME,@END_TIME) AS NVARCHAR) + ' seconds.'
		PRINT '-----------------------------------------'

		-----------------------------------------------------------------------
        -- ERP - Location
        -----------------------------------------------------------------------

		SET @START_TIME = GETDATE(); 
		PRINT '>> Truncating Table		: [Bronze].[Erp_LocA101]';
		TRUNCATE TABLE Bronze.Erp_LocA101;

		PRINT '>> Inserting Data Into	: [Bronze].[Erp_LocA101]';
		BULK INSERT Bronze.Erp_LocA101
		FROM 'C:\Users\rites\Downloads\Data WareHouse Project\sql-data-warehouse-project\datasets\source_erp\Loc_A101.csv'
		WITH
		(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		)
		SET @END_TIME = GETDATE()
		PRINT'>> LOAD DURATION : ' + CAST(DATEDIFF(SECOND,@START_TIME,@END_TIME) AS NVARCHAR) + ' seconds.'
		PRINT '-----------------------------------------'

		-----------------------------------------------------------------------
        -- ERP - Product Category
        -----------------------------------------------------------------------

		SET @START_TIME = GETDATE(); 
		PRINT '>> Truncating Table		: [Bronze].[Erp_PxCatG1V2]';
		TRUNCATE TABLE Bronze.Erp_PxCatG1V2;

		PRINT '>> Inserting Data Into	: [Bronze].[Erp_PxCatG1V2]';
		BULK INSERT Bronze.Erp_PxCatG1V2
		FROM 'C:\Users\rites\Downloads\Data WareHouse Project\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
		WITH
		(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		)
		SET @END_TIME = GETDATE()
		PRINT'>> LOAD DURATION : ' + CAST(DATEDIFF(SECOND,@START_TIME,@END_TIME) AS NVARCHAR) + ' seconds.'
		PRINT '-----------------------------------------'

		-----------------------------------------------------------------------
        -- Capture Batch End Time
        -----------------------------------------------------------------------
		SET @BATCH_END_TIME = GETDATE()
		PRINT'>> BATCH LOAD DURATION : ' + CAST(DATEDIFF(SECOND,@BATCH_START_TIME,@BATCH_END_TIME) AS NVARCHAR) + ' seconds.'

		PRINT '-----------------------------------------------------------------------------------------------------------------------';
		PRINT 'DATA LOAD TO BRONZE LAYER COMPLETED SUCCESSFULLY.';
		PRINT '-----------------------------------------------------------------------------------------------------------------------';
	END TRY

	---------------------------------------------------------------------------
    -- Error Handling Section
    ---------------------------------------------------------------------------

	BEGIN CATCH
		PRINT'=================================================================';
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER'
		PRINT 'Error Message	: ' + ERROR_MESSAGE();
		PRINT 'Error Number     : ' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error State		: ' + CAST(ERROR_STATE()  AS NVARCHAR);
		PRINT'=================================================================';
		-----------------------------------------------------------------------
        -- Re-throw error to ensure calling process detects failure
        -----------------------------------------------------------------------
		THROW;
	END CATCH

END
GO