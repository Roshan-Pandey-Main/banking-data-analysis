/* Import the CSV/dataset file as Flat file in SQL server or maunal load file by using
LOAD DATA INFILE 'path/to/transactions.csv'
INTO TABLE transactions
FIELDS TERMINATED BY ','
IGNORE 1 ROWS; 
------------------------------------------------------------------------------------------------------------
Once the file is import then clean the data by running the following query
*/
SELECT 
    REPLACE(Account_No, '''', '') AS Account_No,
    CAST(DATE AS DATE) AS transaction_date,
    TRANSACTION_DETAILS,
    CHQ_NO,
    CAST(VALUE_DATE AS DATE) AS value_date,

    TRY_CAST(REPLACE(NULLIF(WITHDRAWAL_AMT, ''), ',', '') AS DECIMAL(18,2)) AS withdrawal_amt,

    TRY_CAST(REPLACE(NULLIF(DEPOSIT_AMT, ''), ',', '') AS DECIMAL(18,2)) AS deposit_amt,

    TRY_CAST(REPLACE(NULLIF(BALANCE_AMT, ''), ',', '') AS DECIMAL(18,2)) AS balance_amt

INTO final_transactions
FROM "transaction";    ---had to put trnasction in double qoutes since its a prepfined function SQL
