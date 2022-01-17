-- Description of the Tables in the database

SELECT 'Customers' AS table_name, 
       13 AS number_of_attribute,
       COUNT(*) AS number_of_row
  FROM Customers
  
UNION ALL

SELECT 'Products' AS table_name, 
       9 AS number_of_attribute,
       COUNT(*) AS number_of_row
  FROM Products

UNION ALL

SELECT 'ProductLines' AS table_name, 
       4 AS number_of_attribute,
       COUNT(*) AS number_of_row
  FROM ProductLines

UNION ALL

SELECT 'Orders' AS table_name, 
       7 AS number_of_attribute,
       COUNT(*) AS number_of_row
  FROM Orders

UNION ALL

SELECT 'OrderDetails' AS table_name, 
       5 AS number_of_attribute,
       COUNT(*) AS number_of_row
  FROM OrderDetails

UNION ALL

SELECT 'Payments' AS table_name, 
       4 AS number_of_attribute,
       COUNT(*) AS number_of_row
  FROM Payments

UNION ALL

SELECT 'Employees' AS table_name, 
       8 AS number_of_attribute,
       COUNT(*) AS number_of_row
  FROM Employees

UNION ALL

SELECT 'Offices' AS table_name, 
       9 AS number_of_attribute,
       COUNT(*) AS number_of_row
  FROM Offices;

-- SOLUTION 1
-- Calculate stocks and limit to only the top 10 low stock

SELECT productName,o.productCode,ROUND(SUM(quantityordered)/(SELECT SUM(quantityInStock)
											FROM products p
                                            Where p.productCode = o.productCode),2)low_stock
FROM orderdetails o
JOIN products p
ON p.productCode = o.productCode
GROUP BY 1
ORDER BY 3
LIMIT 10;

-- Determine the Product Performance
SELECT productName,od.productCode, 
       SUM(quantityOrdered * priceEach) AS prod_perf
  FROM orderdetails od
  JOIN products p
  ON p.productCode = od.productCode
 GROUP BY od.productCode 
 ORDER BY prod_perf DESC
 LIMIT 10;
 
 -- Priority Products for restocking SOLUTION 1
WITH 
low_stock_table AS (
SELECT p.productCode, 
       ROUND(SUM(quantityOrdered) * 1.0/(SELECT quantityInStock
                                           FROM products p
                                          WHERE od.productCode = p.productCode), 2) AS low_stock, p.productName AS product_name
  FROM orderdetails od
  JOIN products p
  ON p.productCode = od.ProductCode
 GROUP BY productCode
 ORDER BY low_stock
 LIMIT 10
)
SELECT od.productCode,l.product_name,
       SUM(quantityOrdered * priceEach) AS prod_perf
  FROM orderdetails od
  JOIN low_stock_table l
  ON od.productCode = l.productCode
 WHERE od.productCode IN (SELECT productCode
                         FROM low_stock_table)
 GROUP BY productCode 
 ORDER BY prod_perf DESC
 LIMIT 10;
 
-- Priority Products for restocking SOLUTION 2
WITH low_Stock_table AS (
SELECT o.productCode,ROUND(SUM(quantityordered)/(SELECT SUM(quantityInStock)
											FROM products p
                                            Where p.productCode = o.productCode),2)low_stock
FROM orderdetails o
JOIN products p
ON p.productCode = o.productCode
GROUP BY 1
ORDER BY 2
LIMIT 10)
SELECT p.productName,od.productCode, 
       SUM(quantityOrdered * priceEach) AS prod_perf
  FROM orderdetails od
  JOIN products p
  ON p.productCode = od.productCode
  WHERE od.productCode IN (SELECT productCode
                         FROM low_stock_table)
 GROUP BY productCode 
 ORDER BY prod_perf DESC
 LIMIT 10;
 
 -- SOLUTION 3 
 -- 1 Write a query to join the products, orders, and orderdetails tables to have customers and products information in the same place
 
 SELECT o.customerNumber,p.buyPrice,od.quantityOrdered,od.priceEach 
 from products p
JOIN orderdetails od
 ON od.productCode = p.productCode
 JOIN orders o
 ON od.orderNumber = o.orderNumber;
 
 -- 2. Compute, for each customer, the profit, which is the sum of quantityOrdered multiplied by priceEach minus buyPrice: 
 -- SUM(quantityOrdered * (priceEach - buyPrice))
 
 SELECT o.customerNumber,SUM(od.quantityOrdered * (od.priceEach - p.buyPrice)) AS profit
 from products p
JOIN orderdetails od
 ON od.productCode = p.productCode
 JOIN orders o
 ON od.orderNumber = o.orderNumber
 GROUP BY 1
 ORDER BY 2 DESC;
 
 -- Use the query from the solution 2 as a CTE.
 -- Select the following columns: contactLastName, contactFirstName, city, and country from the customers table and the profit from the CTE.
 
 -- TOP 5 VIP customers
 WITH compute_profit AS 
 (
 SELECT o.customerNumber,SUM(od.quantityOrdered * (od.priceEach - p.buyPrice)) AS profit
 from products p
 JOIN orderdetails od
 ON od.productCode = p.productCode
 JOIN orders o
 ON od.orderNumber = o.orderNumber
 GROUP BY 1
 )
 SELECT contactLastName, contactFirstName, profit,city,country
 FROM customers c
 JOIN compute_profit cp
 ON c.customerNumber = cp.customerNumber
 ORDER BY 3 DESC
 LIMIT 5;
 
-- TOP LIST ENGAGING CUSTOMERS
WITH compute_profit AS 
 (
 SELECT o.customerNumber,SUM(od.quantityOrdered * (od.priceEach - p.buyPrice)) AS profit
 from products p
 JOIN orderdetails od
 ON od.productCode = p.productCode
 JOIN orders o
 ON od.orderNumber = o.orderNumber
 GROUP BY 1
 )
 SELECT contactLastName, contactFirstName, profit,city,country
 FROM customers c
 JOIN compute_profit cp
 ON c.customerNumber = cp.customerNumber
 ORDER BY 3
 LIMIT 5; 
 
 
 -- Write a query to compute the average of customer profits using the compute_profit table on the previous screen.
WITH compute_profit AS 
 (
 SELECT o.customerNumber AS customerNumber,SUM(od.quantityOrdered * (od.priceEach - p.buyPrice)) AS profit
 from products p
 JOIN orderdetails od
 ON od.productCode = p.productCode
 JOIN orders o
 ON od.orderNumber = o.orderNumber
 GROUP BY 1
 )
 SELECT ROUND(AVG(profit),2) as avg_profit
 FROM compute_profit;
 