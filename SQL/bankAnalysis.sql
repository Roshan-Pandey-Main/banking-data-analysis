/*Basic Overview
Insight:
Dataset size
Customer base*/

SELECT 
    SUM(withdrawal_amt) AS total_spent,
    SUM(deposit_amt) AS total_received
FROM final_transactions;

/*Total Money Flow
Overall inflow vs outflow
*/
select 
count(*) as total_transaction,
count(distinct Account_No) as total_account
from final_transactions;

/* Average Transaction Size */
SELECT 
    AVG(deposit_amt) AS avg_credit,
    AVG(withdrawal_amt) AS avg_debit
FROM final_transactions;

/*Monthly Trend*/

SELECT 
    YEAR(transaction_date) AS year,
    MONTH(transaction_date) AS month,
    SUM(deposit_amt) AS total_credit,
    SUM(withdrawal_amt) AS total_debit
FROM final_transactions
GROUP BY YEAR(transaction_date), MONTH(transaction_date)
ORDER BY year, month;

/*top accounts(high value customers)*/

SELECT 
    Account_No,
    SUM(deposit_amt) AS total_credit,
    SUM(withdrawal_amt) AS total_debit,
    SUM(deposit_amt) - SUM(withdrawal_amt) AS net_flow,

    CASE 
        WHEN SUM(deposit_amt) > 500000 AND SUM(withdrawal_amt) < SUM(deposit_amt)
            THEN 'High Value'
        WHEN SUM(deposit_amt) > 500000 AND SUM(withdrawal_amt) >= SUM(deposit_amt)
            THEN 'High Activity'
        WHEN SUM(deposit_amt) < 50000 AND SUM(withdrawal_amt) > SUM(deposit_amt)
            THEN 'Risky'
        ELSE 'Low Engagement'
    END AS customer_segment

INTO customer_summary
FROM final_transactions
GROUP BY Account_No;

/*High Value Transactions (Fraud Angle)
Unusual behavior for that specific customer*/
SELECT *
FROM (
    SELECT 
        Account_No,
        transaction_date,
        withdrawal_amt,
        AVG(withdrawal_amt) OVER (PARTITION BY Account_No) AS avg_amt
    FROM final_transactions
) t
WHERE withdrawal_amt > avg_amt * 3;

-----OR------
--for large dataset aggregated tables+joins--
SELECT 
    Account_No,
    AVG(withdrawal_amt) AS avg_amt
INTO customer_avg
FROM final_transactions
GROUP BY Account_No;

SELECT t.*
FROM final_transactions t
JOIN customer_avg a
ON t.Account_No = a.Account_No
WHERE t.withdrawal_amt > a.avg_amt * 3;

--Transaction Type Split--
SELECT 
    CASE 
        WHEN withdrawal_amt IS NOT NULL THEN 'Debit'
        ELSE 'Credit'
    END AS transaction_type,
    COUNT(*) AS transaction_count
FROM final_transactions
GROUP BY 
    CASE 
        WHEN withdrawal_amt IS NOT NULL THEN 'Debit'
        ELSE 'Credit'
    END;


--Daily Spending Pattern--
    SELECT 
    Account_No,
    transaction_date,
    COALESCE(SUM(withdrawal_amt),0) AS daily_spend
FROM final_transactions
GROUP BY Account_No,transaction_date
ORDER BY Account_No,transaction_date;


--Running Balance Check--

SELECT 
    Account_No,
    transaction_date,
    balance_amt,
    LAG(balance_amt) OVER (PARTITION BY Account_No ORDER BY transaction_date) AS prev_balance
FROM final_transactions;

--or----
SELECT 
    Account_No,
    transaction_date,
    balance_amt,
    LAG(balance_amt) OVER (
        PARTITION BY Account_No 
        ORDER BY transaction_date
    ) AS prev_balance,

    balance_amt - LAG(balance_amt) OVER (
        PARTITION BY Account_No 
        ORDER BY transaction_date
    ) AS balance_change

FROM final_transactions;

--Top 5 Transactions per Account--

SELECT *
FROM (
    SELECT 
        Account_No,
        transaction_date,
        COALESCE(deposit_amt, withdrawal_amt) AS amount,
        ROW_NUMBER() OVER (PARTITION BY Account_No ORDER BY COALESCE(deposit_amt, withdrawal_amt) DESC) AS rn
    FROM final_transactions
) t
WHERE rn <= 5;
