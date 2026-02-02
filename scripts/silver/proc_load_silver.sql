*/
=============================================================================
stored Procedure: Load Silver Layer (Source-> Silver)
=============================================================================
Script Purpose:
  This stored procedure perform the ETL ( Extract, Transform, Load) process to
  populate the 'silver' schema tables from the 'bronze' schema.
Actions Performed:
  -Truncating Silver tables.
  -Inserts transformed and cleansed data from Bronze into Silver tables

Parameters:
  None.
  This stored procedure does not accept any parameters or return any values.

Usage Example:
  EXEC silver.load_silver;
============================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
   
     DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
     BEGIN TRY
      PRINT '================================================================';
     PRINT 'Loading silver Layer';
     PRINT '================================================================';
  
     PRINT '----------------------------------------------------------------';
     PRINT 'Loading CRM Tables';
     PRINT '----------------------------------------------------------------';
     SET @batch_start_time = GETDATE();
      PRINT '>> Truncating Table: silver.Crm_Cust_info';
      TRUNCATE TABLE silver.Crm_Cust_info;
      PRINT '>> Inserting Data Into Table: silver.Crm_Cust_info';
      INSERT INTO silver.Crm_Cust_info(
      cst_id,
      Cst_key,
      Cst_firstname,
      Cst_lastname,
      Cst_material_status,
      Cst_gndr,
      Cst_create_date
      )
      SELECT
      cst_id,
      Cst_key,
      TRIM(Cst_firstname) AS Cst_firstname,
      TRIM(Cst_lastname) AS Cst_lastname,
  
      CASE WHEN UPPER(TRIM(Cst_material_status)) = 'S'THEN 'Single'
  	     WHEN UPPER (TRIM(Cst_material_status)) = 'M' THEN 'Married'
           ELSE 'n/a'
      END AS Cst_material_status,
  
      CASE WHEN UPPER(TRIM(cst_gndr)) = 'M'THEN 'Female' 
  	     WHEN UPPER (TRIM(cst_gndr)) = 'f' THEN 'Male'
           ELSE 'n/a'
      END AS Cst_gndr,
  
      Cst_create_date
      FROM(
      SELECT
      *,
      ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
      FROM bronze.Crm_Cust_info
      WHERE cst_id IS NOT NULL
      ) AS T
      WHERE flag_last = 1;
        SET @end_time = GETDATE();
     PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR(10)) + ' seconds';
     PRINT '--------------------';
  
  
      SET @start_time = GETDATE();
      PRINT '>> Truncating Table: silver.crm_prd_info';
      TRUNCATE TABLE silver.crm_prd_info;
      PRINT '>> Inserting Data Into Table: silver.crm_prd_info';
      INSERT INTO silver.crm_prd_info(
      prd_id,
      prd_Key,
      prd_nm,
      prd_cost,
      prd_line,
      prd_start_dt,
      prd_end_dt
      )	
      SELECT
      prd_id,
      REPLACE(SUBSTRING(prd_key,1,5),'-','') AS cat_id,
      SUBSTRING(prd_key,7,LEN(prd_key)) AS prd_nm,
      ISNULL(prd_cost,0) AS prd_cost,
      CASE    WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
              WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
              WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
              WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
  	     ELSE 'n/a'
      END AS prd_line,
      CAST(prd_start_dt AS DATE) AS prd_start_dt,
      LEAD(prd_start_dt) OVER (PARTITION BY prd_id ORDER BY prd_start_dt DESC) AS prd_end_dt
      FROM bronze.crm_prd_info
      SET @end_time = GETDATE();
  PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR(10)) + ' seconds';
  PRINT '--------------------';
  
  
  
  
      SET @start_time = GETDATE();
      PRINT '>> Truncating Table: silver.crm_sales_details';
      TRUNCATE TABLE silver.crm_sales_details;
      PRINT '>> Inserting Data Into Table: silver.crm_sales_details';
      INSERT INTO silver.crm_sales_details(
          sls_ord_num,
          sls_prd_key,
          sls_cust_id,
          sls_order_id,
          sls_ship_dt,
          sls_due_dt,
          sls_sales,
          sls_quantity,
          sls_price
      )
      SELECT
          b.sls_ord_num,
          b.sls_prd_key,
          b.sls_cust_id,
          CASE WHEN b.sls_order_id IS NULL OR b.sls_order_id = 0 OR LEN(CAST(b.sls_order_id AS VARCHAR(10))) <> 8 
               THEN NULL ELSE b.sls_order_id END,
          CASE WHEN b.sls_ship_dt IS NULL  OR b.sls_ship_dt  = 0 OR LEN(CAST(b.sls_ship_dt  AS VARCHAR(10))) <> 8 
               THEN NULL ELSE b.sls_ship_dt END,
          CASE WHEN b.sls_due_dt IS NULL   OR b.sls_due_dt   = 0 OR LEN(CAST(b.sls_due_dt   AS VARCHAR(10))) <> 8 
               THEN NULL ELSE b.sls_due_dt END,
          CASE WHEN b.sls_sales IS NULL OR b.sls_sales <= 0 OR b.sls_sales <> b.sls_quantity * ABS(ISNULL(b.sls_price,0))
               THEN b.sls_quantity * ABS(ISNULL(b.sls_price,0))
               ELSE b.sls_sales END AS sls_sales,
          b.sls_quantity,
          CASE WHEN b.sls_price IS NULL OR b.sls_price <= 0
               THEN CASE WHEN b.sls_quantity = 0 THEN NULL ELSE b.sls_sales / NULLIF(b.sls_quantity,0) END
               ELSE b.sls_price END AS sls_price
      FROM bronze.crm_sales_details AS b;
      SET @end_time = GETDATE();
  PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR(10)) + ' seconds';
  PRINT '--------------------';
  
  
  
  
      SET @start_time = GETDATE();
      PRINT '>> Truncating Table: silver.erp_cust_az12';
      TRUNCATE TABLE silver.erp_cust_az12;
      PRINT '>> Inserting Data Into Table: silver.erp_cust_az12';
      INSERT INTO silver.erp_cust_az12(
      cid,
      bdate,
      gen
      )
      SELECT
      REPLACE (cid, 'NAS', '') AS cid,
      CASE WHEN bdate > GETDATE() THEN NULL
      ELSE bdate
      END AS bdate,
      CASE WHEN UPPER(TRIM(gen)) IN ('F','FEMALE') THEN 'Female'
           WHEN UPPER(TRIM(gen)) IN ('M','MALE') THEN 'Male'
           ELSE 'n/a'
           END AS gen
           FROM bronze.erp_cust_az12
           SET @end_time = GETDATE();
  PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR(10)) + ' seconds';
  PRINT '--------------------';
  
  
  
      SET @start_time = GETDATE();
      PRINT '>> Truncating Table: silver.erp_loc_a101';
      TRUNCATE TABLE silver.erp_loc_a101;
      PRINT '>> Inserting Data Into Table: silver.erp_loc_a101';
      INSERT INTO silver.erp_loc_a101
      (cid, cntry)
      SELECT 
      REPLACE (cid,'-','') cid,
      CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany'
  	     WHEN TRIM(cntry) IN ('US' , 'USA') THEN 'United states'
  	     WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
      ELSE TRIM(cntry)
      END AS cntry
      FROM bronze.erp_loc_a101
      SET @end_time = GETDATE();
      PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR(10)) + ' seconds';
      PRINT '--------------------';
  
  
  
      SET @start_time = GETDATE();
      PRINT '>> Truncating Table: silver.erp_px_cat_g1v2';
      TRUNCATE TABLE silver.erp_px_cat_g1v2;
      PRINT '>> Inserting Data Into Table: silver.erp_px_cat_g1v2';
      INSERT INTO silver.erp_px_cat_g1v2
      (id,cat,subcat,maintenance)
      SELECT 
      id,
      cat,
      subcat,
      maintenance
      FROM bronze.erp_px_cat_g1v2
      SET @end_time = GETDATE();
  PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR(10)) + ' seconds';
  PRINT '--------------------';
  
  
      SET @batch_end_time = GETDATE();
  PRINT '================================================================';
  PRINT ' Loading Silver Layer Completed ';
  PRINT ' - Total Batch Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS VARCHAR(10)) + ' seconds';
  PRINT '================================================================';
  
  
  END TRY
  BEGIN CATCH
  PRINT '================================================================';
  PRINT 'Error occurred while loading Bronze Layer: ' + ERROR_MESSAGE();
  PRINT '================================================================';
  END CATCH
  END
