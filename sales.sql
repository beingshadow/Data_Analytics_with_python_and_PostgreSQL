select * from customer_data;
-- find the top 10 product highest generating revenue product
SELECT 
product_id,SUM(sale_price) as sales
FROM customer_data
GROUP BY 1
ORDER BY sales DESC
LIMIT 10;

-- find the top 5 product highest selling product by each region 
WITH cte as(select product_id,region ,SUM(sale_price) as sale,
DENSE_RANK() OVER(PARTITION BY region ORDER BY SUM(sale_price) DESC) as top_5_product 
FROM customer_data
GROUP BY 1,2 )

select * from cte
where top_5_product<=5;

-- select month over month comparsion for 2022 and 2023 means jan 2022 a
WITH cte AS (
    SELECT 
        EXTRACT(YEAR FROM order_date) AS order_year,
        EXTRACT(MONTH FROM order_date) AS order_month,
        SUM(sale_price) AS sales
    FROM customer_data
    GROUP BY 1, 2
)
SELECT 
    order_month,
    SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) AS year_2022,
    SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) AS year_2023
FROM cte
GROUP BY order_month
ORDER BY order_month;

--for each category which month had highest sales 
WITH CTE AS (
    SELECT 
        EXTRACT(MONTH FROM order_date) AS order_month,
        category,
        EXTRACT(YEAR FROM order_date) AS order_year,
        SUM(sale_price) AS sales,
        ROW_NUMBER() OVER(PARTITION BY category, EXTRACT(YEAR FROM order_date) 
                          ORDER BY SUM(sale_price) DESC) AS rnk
    FROM customer_data
    GROUP BY EXTRACT(MONTH FROM order_date), category, EXTRACT(YEAR FROM order_date)
),
cte2 AS (
    SELECT 
        order_year, order_month, category, sales
    FROM CTE 
    WHERE rnk = 1
),
cte3 AS (
    SELECT 
        order_year,
        order_month,
        category,
        sales,
        ROW_NUMBER() OVER(PARTITION BY category ORDER BY sales DESC) AS rnk1
    FROM cte2
)
SELECT 
category,
sales
FROM cte3
WHERE rnk1 = 1;

--which sub category had highest growth by profit in 2023 compare to 2022

WITH cte AS (
    SELECT 
	    sub_category,
        EXTRACT(YEAR FROM order_date) AS order_year,
        SUM(sale_price) AS sales
    FROM customer_data
    GROUP BY 1,2
),cte2 as(
SELECT 
    sub_category,
    SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) AS year_2022,
    SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) AS year_2023
FROM cte
GROUP BY 1
)

select *,((year_2023-year_2022)/year_2022)*100 as profit
from cte2
order by profit desc
LIMIT 5;