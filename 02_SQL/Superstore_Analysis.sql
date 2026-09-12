create database superstore;
use superstore;

select*from superstore_cleaned
limit 10;

describe superstore_cleaned;

-- 1.Total Sales

SELECT
    SUM(Sales) AS Total_Sales
FROM superstore_cleaned;

-- 2.Total Profit

SELECT
    SUM(Profit) AS Total_Profit
FROM superstore_cleaned;

-- 3.Total Order

SELECT
    COUNT(DISTINCT Order_ID) AS Total_Orders
FROM superstore_cleaned;


-- 4.Total quantity

SELECT
    SUM(Quantity) AS Total_Quantity
FROM superstore_cleaned;

-- 5.Sales By Category 

SELECT 
    Category,
    SUM(Sales) AS Total_Sales
FROM superstore_Cleaned
GROUP BY Category
ORDER BY Total_Sales DESC;

-- 6.Profit By Category 

SELECT 
    Category,
    SUM(Profit) AS Total_Profit
FROM superstore_Cleaned
GROUP BY Category
ORDER BY Total_Profit DESC;

-- 7.Sales BY Region

SELECT 
    Region,
    SUM(Sales) AS Total_Sales
FROM superstore_Cleaned
GROUP BY Region
ORDER BY Total_Sales DESC;

-- 8.Profit by Region

SELECT 
    Region,
    SUM(Profit) AS Total_Profit
FROM superstore_Cleaned
GROUP BY Region
ORDER BY Total_Profit DESC;

-- 9.Monthly sales

SELECT 
    YEAR(STR_TO_DATE(Order_Date, '%d-%m-%y')) AS Year,
    MONTH(STR_TO_DATE(Order_Date, '%d-%m-%y')) AS Month,
    SUM(Sales) AS Total_Sales
FROM superstore_Cleaned
GROUP BY 
    YEAR(STR_TO_DATE(Order_Date, '%d-%m-%y')),
    MONTH(STR_TO_DATE(Order_Date, '%d-%m-%y'))
ORDER BY Year, Month;

-- 10. Year Wise Performance

SELECT 
    Year,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit,
    SUM(Quantity) AS Total_Quantity
FROM superstore_Cleaned
GROUP BY Year
ORDER BY Year;

-- 11.Top 10 Products by sales

SELECT 
    Product_Name,
    SUM(Sales) AS Total_Sales
FROM superstore_Cleaned
GROUP BY Product_Name
ORDER BY Total_Sales DESC
LIMIT 10;

-- 12.Bottem 10 products by sales

SELECT 
    Product_Name,
    SUM(Sales) AS Total_Sales
FROM superstore_Cleaned
GROUP BY Product_Name
ORDER BY Total_Sales ASC
LIMIT 10;

-- 13.Loss Marketting Products

SELECT 
    Product_Name,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit
FROM superstore_Cleaned
GROUP BY Product_Name
HAVING SUM(Profit) < 0
ORDER BY Total_Profit ASC;

-- 14.Top Coustomers

SELECT 
    Customer_ID,
    Customer_Name,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit
FROM superstore_Cleaned
GROUP BY Customer_ID, Customer_Name
ORDER BY Total_Sales DESC
LIMIT 10;

-- 15.Discount vs Profit

SELECT 
    Discount,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit,
    AVG(Profit) AS Average_Profit
FROM superstore_Cleaned
GROUP BY Discount
ORDER BY Discount;

-- 16.Top 3 products with Each Category

WITH ProductSales AS (
    SELECT
        Category,
        Product_Name,
        SUM(Sales) AS Total_Sales,
        ROW_NUMBER() OVER (
            PARTITION BY Category
            ORDER BY SUM(Sales) DESC
        ) AS Rank_No
    FROM superstore_Cleaned
    GROUP BY Category, Product_Name
)
SELECT
    Category,
    Product_Name,
    Total_Sales,
    Rank_No
FROM ProductSales
WHERE Rank_No <= 3
ORDER BY Category, Rank_No;

-- 17.Coustomers whose sales are above Average

SELECT 
    Customer_ID,
    Customer_Name,
    SUM(Sales) AS Total_Sales
FROM superstore_Cleaned
GROUP BY Customer_ID, Customer_Name
HAVING SUM(Sales) > (
    SELECT AVG(Customer_Sales)
    FROM (
        SELECT 
            Customer_ID,
            SUM(Sales) AS Customer_Sales
        FROM superstore_Cleaned
        GROUP BY Customer_ID
    ) AS CustomerTotals
)
ORDER BY Total_Sales DESC;

-- 18.Monthly Sales Growth 

WITH MonthlySales AS (
    SELECT
        YEAR(STR_TO_DATE(Order_Date, '%d-%m-%y')) AS Sales_Year,
        MONTH(STR_TO_DATE(Order_Date, '%d-%m-%y')) AS Sales_Month,
        SUM(Sales) AS Total_Sales
    FROM superstore_Cleaned
    GROUP BY
        YEAR(STR_TO_DATE(Order_Date, '%d-%m-%y')),
        MONTH(STR_TO_DATE(Order_Date, '%d-%m-%y'))
),
SalesWithPrevious AS (
    SELECT
        Sales_Year,
        Sales_Month,
        Total_Sales,
        LAG(Total_Sales) OVER (
            ORDER BY Sales_Year, Sales_Month
        ) AS Previous_Month_Sales
    FROM MonthlySales
)
SELECT
    Sales_Year,
    Sales_Month,
    Total_Sales,
    Previous_Month_Sales,
    ROUND(
        ((Total_Sales - Previous_Month_Sales)
        / NULLIF(Previous_Month_Sales, 0)) * 100,
        2
    ) AS Growth_Percentage
FROM SalesWithPrevious
ORDER BY Sales_Year, Sales_Month;

-- 19.Profit margin by Category

SELECT
    Category,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit,
    ROUND(
        (SUM(Profit) / NULLIF(SUM(Sales), 0)) * 100,
        2
    ) AS Profit_Margin_Percentage
FROM superstore_Cleaned
GROUP BY Category
ORDER BY Profit_Margin_Percentage DESC;

-- 20.Best -Performing Product in Each Region

WITH RegionalProducts AS (
    SELECT
        Region,
        Product_Name,
        SUM(Sales) AS Total_Sales,
        SUM(Profit) AS Total_Profit,
        ROW_NUMBER() OVER (
            PARTITION BY Region
            ORDER BY SUM(Sales) DESC
        ) AS Rank_No
    FROM superstore_Cleaned
    GROUP BY Region, Product_Name
)
SELECT
    Region,
    Product_Name,
    Total_Sales,
    Total_Profit
FROM RegionalProducts
WHERE Rank_No = 1
ORDER BY Region;

