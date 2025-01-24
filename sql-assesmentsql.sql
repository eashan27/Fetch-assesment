--What are the top 5 brands by receipts scanned among users 21 and over?
Select p.brand,
           count(t.receipt_id) as receipt_count,
FROM TRANSACTION_TAKEHOME t
JOIN USER_TAKEHOME u ON t.USER_ID = u.ID 
JOIN PRODUCTS_TAKEHOME p ON t.BARCODE = p.BARCODE
Where DATE_PART('year', AGE(CURRENT_DATE, CAST(u.BIRTH_DATE AS DATE))) >= 21



--What are the top 5 brands by sales among users that have had their account for at least six months?
With cte as (
    SELECT 
        t.USER_ID,
        p.BRAND,
        SUM(COALESCE(t.FINAL_SALE, 0)) AS sales -- Using coalesce function to replace null values with 0 to use it with sum function
    FROM 
        TRANSACTION_TAKEHOME t
    JOIN 
        PRODUCTS_TAKEHOME p ON t.BARCODE = p.BARCODE
    Group BY
        t.USER_ID, p.BRAND
)
SELECT 
    cte.BRAND,
    sum(cte.sales) AS total_sales
FROM 
    cte
JOIN 
    USER_TAKEHOME u ON cte.USER_ID = u.ID
WHERE 
    CURRENT_DATE - CAST(u.CREATED_DATE AS DATE) >= INTERVAL '6 months'
GROUP BY 
    cte.BRAND
ORDER BY 
    total_sales desc
Limit 5;

--Which is the leading brand in the Dips & Salsa category?

With cte as (
    SELECT 
        p.BRAND,
        SUM(COALESCE(t.SALE, 0)) AS sales,
        RANK() OVER (ORDER BY SUM(COALESCE(t.SALE, 0)) DESC) AS rank_ -- using rank window function to get the leading brand
    FROM 
        TRANSACTION_TAKEHOME t
    INNER JOIN 
        PRODUCTS_TAKEHOME p ON t.BARCODE = p.BARCODE
    WHERE 
        p.CATEGORY_2 = 'Dips & Salsa'
    GROUP BY 
        p.BRAND
)
SELECT 
    BRAND,
    sales
FROM 
    cte
WHERE 
    rank_ = 1;
