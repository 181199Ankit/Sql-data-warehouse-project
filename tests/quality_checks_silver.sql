/*
=====================================================================
Quality Checks
=====================================================================

Script Purpose:
    This script performs various quality checks for data consistency, accuracy,
    and standardization across the 'silver' schemas. It includes checks for:

    - Null or duplicate primary keys.
    - Unwanted spaces in string fields.
    - Data standardization and consistency.
    - Invalid date ranges and orders.
    - Data consistency between related fields.

Usage Notes:
    - Run these checks after data loading Silver Layer.
    - Investigate and resolve any discrepancies found during the checks.
=====================================================================
*/

-- ================================================================
-- Checking 'silver.crm_cust_info'
-- ================================================================

-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No Results
SELECT
   cst_id,
   COUNT(*)
FROM silver.crm_crust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;
- Check for Unwanted Spaces
-- Expectation: No Results
SELECT
    cst_key
FROM silver.crm_cust_info
WHERE cst_key != TRIM(cst_key);

-- Data Standardization & Consistency
SELECT DISTINCT
    cst_marital_status
FROM silver.crm_cust_info;

-- =====================================================
-- Checking 'silver.crm_prd_info'
-- =====================================================

-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No Results
SELECT
    prd_id,
    COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- Check for Unwanted Spaces
-- Expectation: No Results
SELECT
-- Checking 'silver.crm_cust_info'
-- =====================================================

-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No Results
SELECT
    cst_id,
    COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- Check for Unwanted Spaces
-- Expectation: No Results
SELECT
    cst_key
FROM silver.crm_cust_info
WHERE cst_key != TRIM(cst_key);

-- Data Standardization & Consistency
SELECT DISTINCT
    cst_marital_status
FROM silver.crm_cust_info;


-- =====================================================
-- Checking 'silver.crm_prd_info'
-- =====================================================

-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No Results
SELECT
    prd_nm
FROM silver.crm_prd_info
WHERE prd_nm ! = TRIM(prd_nm);
--Check for NULLs or Negative Values in Cost
--Expectation: No Results
SELECT
 prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

--Data standarization & Consistency 
