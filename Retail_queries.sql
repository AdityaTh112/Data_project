-- Top 10 Highest Revenue-Generating Products
SELECT 
    RANK() OVER(ORDER BY SUM(sale_price) DESC) AS prod_rank, 
    product_id, 
    SUM(sale_price) AS total_sales
FROM df_orders
GROUP BY product_id
LIMIT 10;

--  Preview the Data
SELECT * FROM df_orders;

-- Top 5 Highest Selling Products in Each Region (by Revenue)
WITH cte AS (
    SELECT region, product_id, SUM(sale_price) AS sales
    FROM df_orders
    GROUP BY region, product_id
)
SELECT * 
FROM (
    SELECT *, RANK() OVER (PARTITION BY region ORDER BY sales DESC) AS rn 
    FROM cte
) A
WHERE rn <= 5;

--  Month-over-Month Sales Comparison for 2022 and 2023
WITH cte AS (
    SELECT 
        YEAR(order_date) AS order_year, 
        MONTH(order_date) AS order_month, 
        SUM(sale_price) AS sales
    FROM df_orders
    GROUP BY YEAR(order_date), MONTH(order_date)
)
SELECT 
    order_month,
    SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) AS sales_2022,
    SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) AS sales_2023
FROM cte
GROUP BY order_month
ORDER BY order_month;

--  Month with the Highest Sales per Category
WITH cte AS (
    SELECT 
        category, 
        MONTH(order_date) AS months, 
        SUM(sale_price) AS sum_sales
    FROM df_orders
    GROUP BY category, MONTH(order_date)
)
SELECT * 
FROM (
    SELECT *, RANK() OVER (PARTITION BY category ORDER BY sum_sales DESC) AS rnk 
    FROM cte
) ranked
WHERE rnk = 1
ORDER BY category, months;

--  Sub-Category with Highest Growth in 2023 vs 2022
WITH cte AS (
    SELECT 
        sub_category,
        YEAR(order_date) AS order_year,
        SUM(sale_price) AS sales
    FROM df_orders
    GROUP BY sub_category, order_year
),
cte2 AS (
    SELECT 
        sub_category,
        SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) AS sales_2022,
        SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) AS sales_2023
    FROM cte
    GROUP BY sub_category
)
SELECT *, 
    (sales_2023 - sales_2022) * 100 / sales_2022 AS growth
FROM cte2
ORDER BY growth DESC
LIMIT 1;

--  Top-Selling Sub-Category in Each Region
WITH cte AS (
    SELECT sub_category, region, SUM(sale_price) AS total_sales 
    FROM df_orders
    GROUP BY sub_category, region
)
SELECT * 
FROM (
    SELECT *, RANK() OVER (PARTITION BY region ORDER BY total_sales DESC) AS `rank` 
    FROM cte
) ranked 
WHERE `rank` = 1;

--  Most Profitable Category per Segment
WITH cte AS (
    SELECT segment, category, SUM(profit) AS total_profit 
    FROM df_orders
    GROUP BY segment, category
)
SELECT * 
FROM (
    SELECT *, RANK() OVER (PARTITION BY segment ORDER BY total_profit DESC) AS rnk 
    FROM cte
) ranked
WHERE rnk = 1;

--  Best-Selling Product (by Quantity) in Each State
WITH cte AS (
    SELECT state, product_id, SUM(quantity) AS quant_sum 
    FROM df_orders
    GROUP BY state, product_id
)
SELECT * 
FROM (
    SELECT *, RANK() OVER (PARTITION BY state ORDER BY quant_sum DESC) AS rnked 
    FROM cte
) ranked
WHERE rnked = 1;



--  Year-on-Year Sales Growth by Category (2022 vs 2023)
WITH cte AS (
    SELECT 
        category, 
        YEAR(order_date) AS order_year,
        SUM(sale_price) AS total_sales
    FROM df_orders
    GROUP BY category, order_year
),
cte2 AS (
    SELECT 
        category,
        SUM(CASE WHEN order_year = 2022 THEN total_sales ELSE 0 END) AS total_sales_2022,
        SUM(CASE WHEN order_year = 2023 THEN total_sales ELSE 0 END) AS total_sales_2023
    FROM cte
    GROUP BY category
)
SELECT *, 
    (total_sales_2023 - total_sales_2022) * 100 / total_sales_2022 AS growth
FROM cte2
ORDER BY growth DESC;


