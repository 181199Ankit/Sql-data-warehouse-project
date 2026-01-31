*/
=============================================================================
stored Procedure: Load Bronze Layer (Source-> Bronze)
=============================================================================
Script Purpose:
  This stored procedure loadsn data into the 'bronze' schema from external CSV files.
  It performs the following actions:
  - Truncates the bronze tables before loading data.
  - Uses the BULK INSERT command to load data from csv Files to bronze tables.

Parameters:
  None.
  This stored procedure does not accept any parameters or return any values.

Usage Example:
  EXEC bronze.load_bronze;
============================================================================
*/
CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
SET NOCOUNT ON ;

    DECLARE @start_time DATETIME, @end_time DATETIME;
BEGIN TRY

   PRINT'=============================';
   PRINT'Loading Bronze Layer';
   PRINT'=============================';

   PRINT'----------------------------';
   PRINT'Loading CRM Tables';
   PRINT'-----------------------------';
  
  --CRM CUSTOMER INFO
   SET @start_time = GETDATE();

   PRINT '>> Truncating Table: bronze.crm_cust_info';
	TRUNCATE TABLE bronze.crm_cust_info;

	PRINT '>> Inserting Data INTO: bronze.crm_cust_info';
	BULK INSERT bronze.crm_cust_info
	FROM 'F:\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
	WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR =',',
	TABLOCK
	);
	
   SET @end_time = GETDATE();

   PRINT CONCAT('>> Load Duration:',DATEDIFF(second,@start_time,@end_time),' seconds');
   PRINT '>>-----------';

	SELECT * FROM bronze.crm_cust_info

	SET @start_time = GETDATE();
	TRUNCATE TABLE bronze.crm_prd_info;

	BULK INSERT bronze.crm_prd_info
	FROM 'F:\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
	WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR =',',
	TABLOCK
	);
	 SET @end_time = GETDATE();
	   PRINT CONCAT('>> Load Duration:',DATEDIFF(second,@start_time,@end_time),' seconds');
   PRINT '>>-----------';

	SELECT * FROM bronze.crm_prd_info

	 SET @end_time = GETDATE();
	TRUNCATE TABLE bronze.crm_sales_details;
	BULK INSERT bronze.crm_sales_details
	FROM 'F:\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
	WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR =',',
	TABLOCK
	);
	 SET @end_time = GETDATE();
	   PRINT CONCAT('>> Load Duration:',DATEDIFF(second,@start_time,@end_time),' seconds');
   PRINT '>>-----------';

	SELECT * FROM bronze.crm_sales_details

   PRINT'------------------------------------------------------------------------';
   PRINT'Loading ERP Tables';
   PRINT'------------------------------------------------------------------------';

    SET @end_time = GETDATE();
	TRUNCATE TABLE bronze.erp_cust_az12;
	BULK INSERT bronze.erp_cust_az12
	FROM 'F:\sql-data-warehouse-project\datasets\source_erp\cust_az12.csv'
	WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR =',',
	TABLOCK
	);
	 SET @end_time = GETDATE();
  PRINT CONCAT('>> Load Duration:',DATEDIFF(second,@start_time,@end_time),' seconds');
   PRINT '>>-----------';

	SELECT * FROM bronze.erp_cust_az12

	 SET @end_time = GETDATE();
	TRUNCATE TABLE bronze.erp_loc_a101;
	BULK INSERT bronze.erp_loc_a101
	FROM 'F:\sql-data-warehouse-project\datasets\source_erp\loc_a101.csv'
	WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR =',',
	TABLOCK
	);
	 SET @end_time = GETDATE();
  PRINT CONCAT('>> Load Duration:',DATEDIFF(second,@start_time,@end_time),' seconds');
   PRINT '>>-----------';

	SELECT * FROM bronze.erp_loc_a101

	 SET @end_time = GETDATE();
	TRUNCATE TABLE bronze.erp_px_cat_g1v2;
	BULK INSERT bronze.erp_px_cat_g1v2
	FROM 'F:\sql-data-warehouse-project\datasets\source_erp\px_cat_g1v2.csv'
	WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR =',',
	TABLOCK
	);
	 SET @end_time = GETDATE();
	   PRINT CONCAT('>> Load Duration:',DATEDIFF(second,@start_time,@end_time),' seconds');
   PRINT '>>-----------';

	END TRY
	BEGIN CATCH
	PRINT'======================================================';
	PRINT' ERROR OCCURED DURING LOADING BRONZE LAYER';
	PRINT 'ERROR MESSAGE' +ERROR_MESSAGE();
	PRINT 'ERROR MESSAGE' + CAST (ERROR_MESSAGE() AS NVARCHAR);
	PRINT'=====================================================';
	END CATCH

END;
 
