/*
    Southbreeze Database Queries
    Relational Model Demonstration Queries

    These examples assume the Northwind example database's refactored schema 
	and corresponding refactored data
*/

/* ============================================================
   1. CARTESIAN PRODUCT
   ============================================================
   A Cartesian product pairs every row from one table with every row from another table.
   This is rarely what we want in real applications, but it explains why JOIN conditions matter.
*/

-- Which customers have ordered what products
SELECT
    Customer.CompanyName,
    Product.Name as ProductName
FROM Customer
CROSS JOIN Product;

-- Older comma syntax also creates a Cartesian product.
-- This is useful to show students why missing join conditions may be dangerous.
SELECT
    Customer.CompanyName,
    Product.Name as ProductName
FROM Customer, Product;


/* ============================================================
   2. INTEGRITY CONSTRAINTS
   ============================================================
   This intentionally tries to insert invalid data.
   The database should reject this row because CustomerId = -1 does not exist.
*/

BEGIN TRY
    INSERT INTO SalesOrder
    (
        CustomerId,
        EmployeeId,
        ShipperId,
        SalesOrderStatusId,
        OrderDate,
        Freight,
        ShipName,
        IsDeleted,
        CreatedAtUtc
    )
    VALUES
    (
        -1, -- < This is not an actual value in the Customer table
        1,
        1,
        1,
        SYSUTCDATETIME(),
        0.00,
        N'Invalid FK Example',
        0,
        SYSUTCDATETIME()
    );
END TRY
BEGIN CATCH
    SELECT
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_MESSAGE() AS ErrorMessage;
END CATCH;


/* ============================================================
   3. SIMPLE BUSINESS QUESTION EXAMPLES
   ============================================================
*/

-- Question: Which products are currently active and not deleted?
SELECT
    Name,
    UnitPrice,
    UnitsInStock
FROM Product
WHERE IsActive = 1
  AND IsDeleted = 0;

-- Question: Which orders have not shipped yet?
SELECT
    Id,
    OrderDate,
    RequiredDate,
    ShippedDate
FROM SalesOrder
WHERE ShippedDate IS NULL
  AND IsDeleted = 0;

-- Question: Which customers are located in Germany?
SELECT
    CompanyName,
    ContactName,
    City,
    Country
FROM Customer
WHERE Country = N'Germany'
  AND IsDeleted = 0;


/* ============================================================
   4. PROJECT
   ============================================================
   Projection means choosing columns.
   This allows us to select just the columns we want
   It also is independent of the physical way the data is stored,
   which is why it is often called a logical view of the data
*/

SELECT
    CompanyName,
    ContactName,
    Country
FROM Customer;


/* ============================================================
   5. COMBINING SELECT AND PROJECT
   ============================================================
   Relational algebra SELECT means choosing rows.
   SQL SELECT chooses columns, while SQL WHERE filters rows.
*/

SELECT
    Name,
    UnitPrice
FROM Product
WHERE UnitPrice >= 50.00
  AND IsDeleted = 0;


/* ============================================================
   6. JOINS
   ============================================================
*/

/* INNER JOIN / EQUIJOIN
   Shows rows where matching values exist in both tables.
*/
SELECT
    SalesOrder.Id AS SalesOrderId,
    Customer.CompanyName,
    SalesOrder.OrderDate
FROM SalesOrder
INNER JOIN Customer
    -- The FK in SalesOrder is the same as the PK in Customer
    ON SalesOrder.CustomerId = Customer.Id;

/* THETA JOIN
   A theta join uses a comparison other than equality.
   Example: find products that cost more than another product.
*/
SELECT
    Expensive.Name AS MoreExpensiveProduct,
    Expensive.UnitPrice AS MoreExpensivePrice,
    Cheaper.Name AS CheaperProduct,
    Cheaper.UnitPrice AS CheaperPrice
FROM Product AS Expensive
INNER JOIN Product AS Cheaper
    ON Expensive.UnitPrice > Cheaper.UnitPrice
WHERE Expensive.IsDeleted = 0
  AND Cheaper.IsDeleted = 0;

/* LEFT OUTER JOIN
   Returns all customers, and order data when it exists.
   Customers are included even if they do not have any order data
*/
SELECT
    Customer.Id AS CustomerId,
    Customer.CompanyName,
    SalesOrder.Id AS SalesOrderId,
    SalesOrder.OrderDate
FROM Customer -- The first table is the "left" table
LEFT OUTER JOIN SalesOrder -- The second table is the "right" table
    ON Customer.Id = SalesOrder.CustomerId -- The fields mapping records together
ORDER BY Customer.CompanyName;

/* RIGHT OUTER JOIN
   Same type of logic, but preserving rows from the right-side table.
   Many teams avoid RIGHT JOIN because the same query can usually be written as a LEFT JOIN.
*/
SELECT
    Customer.Id AS CustomerId,
    Customer.CompanyName,
    SalesOrder.Id AS SalesOrderId,
    SalesOrder.OrderDate
FROM SalesOrder
RIGHT OUTER JOIN Customer
    ON SalesOrder.CustomerId = Customer.Id
ORDER BY Customer.CompanyName;

/* FULL OUTER JOIN
   Returns matching rows plus unmatched rows from both sides.
   This is useful for comparison/reconciliation problems.
   
   This particular example selects all Customer records and maps
   them to a SalesOrder.  
   Because it is a full outer join, it would also include any 
   SalesOrder records that were not associated with a Customer   
*/
SELECT
    Customer.Id AS CustomerId,
    Customer.CompanyName,
    SalesOrder.Id AS SalesOrderId,
    SalesOrder.OrderDate
FROM Customer
FULL OUTER JOIN SalesOrder
    ON Customer.Id = SalesOrder.CustomerId
ORDER BY Customer.CompanyName;

/* LEFT SEMI JOIN
   SQL Server does not have LEFT SEMI JOIN syntax.
   EXISTS expresses the concept: return rows from the left table when a match exists.
   
   This selects customers who have placed at least one order
*/
SELECT
    Customer.Id,
    Customer.CompanyName
FROM Customer
WHERE EXISTS
(
    SELECT 1 -- Limit the number returned to 1 even if there are more
    FROM SalesOrder
    WHERE SalesOrder.CustomerId = Customer.Id
);

/* RIGHT SEMI JOIN
   SQL Server does not have RIGHT SEMI JOIN syntax.
   Reverse the perspective: return rows from Product that appear in at least one SalesOrderLine.
*/
SELECT
    Product.Id,
    Product.Name
FROM Product
WHERE EXISTS
(
    SELECT 1
    FROM SalesOrderLine
    WHERE SalesOrderLine.ProductId = Product.Id
);

/* NATURAL JOIN
   SQL Server does not support NATURAL JOIN.
   A natural join automatically joins columns with the same name.
   Because our convention uses Id and <Table>Id, natural join is not a good fit.
   We intentionally write the join condition instead.
*/
SELECT
    SalesOrder.Id AS SalesOrderId,
    Customer.CompanyName,
    SalesOrder.OrderDate
FROM SalesOrder
INNER JOIN Customer
    ON SalesOrder.CustomerId = Customer.Id;


/* ============================================================
   7. DIVISION
   ============================================================
   Division answers questions like:
   "Which customers have ordered every product in a required set?"

   Example below: customers who have ordered every product in Category 1.
*/
-- Which products are in Category 1
SELECT
    Product.Id,
    Product.Name
FROM Product
WHERE Product.CategoryId = 1
  AND Product.IsDeleted = 0;

-- How many products are in Category 1. 
--   COUNT(*) counts the rows in the result set instead of showing each 
SELECT COUNT(*) AS RequiredProductCount
FROM Product
WHERE CategoryId = 1
  AND IsDeleted = 0;

-- Who's bought every product in category 1
SELECT 
    Customer.Id,
    Customer.CompanyName
FROM Customer
WHERE NOT EXISTS
(
    SELECT 1
    FROM Product AS RequiredProduct
    WHERE RequiredProduct.CategoryId = 1
      AND RequiredProduct.IsDeleted = 0
      AND NOT EXISTS
      (
          SELECT 1
          FROM SalesOrder
          INNER JOIN SalesOrderLine
              ON SalesOrder.Id = SalesOrderLine.SalesOrderId
          WHERE SalesOrder.CustomerId = Customer.Id
            AND SalesOrderLine.ProductId = RequiredProduct.Id
            AND SalesOrder.IsDeleted = 0
            AND SalesOrderLine.IsDeleted = 0
      )
);
--- Looks like nobody did, but who came closest

SELECT
    Customer.Id,
    Customer.CompanyName,
    COUNT(DISTINCT SalesOrderLine.ProductId) AS Category1ProductsOrdered
FROM Customer
INNER JOIN SalesOrder
    ON Customer.Id = SalesOrder.CustomerId
INNER JOIN SalesOrderLine
    ON SalesOrder.Id = SalesOrderLine.SalesOrderId
INNER JOIN Product
    ON SalesOrderLine.ProductId = Product.Id
WHERE Product.CategoryId = 1
  AND Customer.IsDeleted = 0
  AND SalesOrder.IsDeleted = 0
  AND SalesOrderLine.IsDeleted = 0
  AND Product.IsDeleted = 0
GROUP BY
    Customer.Id,
    Customer.CompanyName
ORDER BY
    Category1ProductsOrdered DESC;


-- To show it works since nobody bought everything in category 1
--   now check which customers ordered product 1 and 2
SELECT
    Customer.Id,
    Customer.CompanyName
FROM Customer
WHERE NOT EXISTS
(
    SELECT RequiredProduct.Id
    FROM Product AS RequiredProduct
    WHERE RequiredProduct.Id IN (1, 2)
      AND NOT EXISTS
      (
          SELECT 1
          FROM SalesOrder
          INNER JOIN SalesOrderLine
              ON SalesOrder.Id = SalesOrderLine.SalesOrderId
          WHERE SalesOrder.CustomerId = Customer.Id
            AND SalesOrderLine.ProductId = RequiredProduct.Id
      )
);


/* ============================================================
   8. SET OPERATIONS
   ============================================================
   UNION, INTERSECT, and EXCEPT require compatible column lists.
*/

/* UNION
   Combines results and removes duplicates.
   Example: list cities that appear in either Customer or Supplier.
*/
SELECT City
FROM Customer
WHERE City IS NOT NULL
UNION
SELECT City
FROM Supplier
WHERE City IS NOT NULL;

/* UNION ALL
   Combines results and keeps duplicates.
*/
SELECT City
FROM Customer
WHERE City IS NOT NULL
UNION ALL
SELECT City
FROM Supplier
WHERE City IS NOT NULL;

/* INTERSECT
   Returns only values that appear in both result sets.
   Example: cities that have both customers and suppliers.
*/
SELECT City
FROM Customer
WHERE City IS NOT NULL
INTERSECT
SELECT City
FROM Supplier
WHERE City IS NOT NULL;

/* EXCEPT
   Difference operation.
   Example: customer cities that are not supplier cities.
*/
SELECT City
FROM Customer
WHERE City IS NOT NULL
EXCEPT
SELECT City
FROM Supplier
WHERE City IS NOT NULL;


/* ============================================================
   9. VIEWS
   ============================================================
   A view stores a reusable query. Run CREATE VIEW after the 
   database tables are created and seeded with data.
*/

CREATE OR ALTER VIEW dbo.ActiveProductCatalog
AS
SELECT
    Product.Id,
    Product.Name as ProductName,
    Category.Name as CategoryName,
    Supplier.CompanyName AS SupplierName,
    Product.UnitPrice,
    Product.UnitsInStock
FROM Product
INNER JOIN Category
    ON Product.CategoryId = Category.Id
INNER JOIN Supplier
    ON Product.SupplierId = Supplier.Id
WHERE Product.IsActive = 1
  AND Product.IsDeleted = 0
  AND Category.IsDeleted = 0
  AND Supplier.IsDeleted = 0;
GO

-- After creating the view:
SELECT
    ProductName,
    CategoryName,
    SupplierName,
    UnitPrice
FROM dbo.ActiveProductCatalog
WHERE UnitPrice >= 25.00;


/* ============================================================
   10. RECURSIVE RELATIONSHIPS FOR HIERARCHY
   ============================================================
   Employee.ReportsToEmployeeId points back to Employee.Id
   This query shows employees and their direct managers
*/

SELECT
    Employee.Id AS EmployeeId,
    Employee.FirstName + N' ' + Employee.LastName AS EmployeeName,
    Manager.Id AS ManagerId,
    Manager.FirstName + N' ' + Manager.LastName AS ManagerName
FROM Employee
LEFT JOIN Employee AS Manager
    ON Employee.ReportsToEmployeeId = Manager.Id
ORDER BY ManagerName, EmployeeName;

/* Recursive example: show reporting hierarchy.
   The anchor query finds top-level employees with no manager.
   The recursive part finds employees who report to someone already in the hierarchy.
*/

WITH EmployeeHierarchy AS  -- Build a temporary view of the recursive data
(
    SELECT -- This gets the company president/CEO
        Employee.Id,
        Employee.FirstName,
        Employee.LastName,
        Employee.ReportsToEmployeeId,
        0 AS HierarchyLevel,
        CAST(Employee.FirstName + N' ' + Employee.LastName AS NVARCHAR(MAX)) AS HierarchyPath
    FROM Employee
    WHERE Employee.ReportsToEmployeeId IS NULL

    UNION ALL -- Combines results and keeps duplicates

    -- This selects all employees at each level below the president/CEO
	-- and appends all managers above them to the HierarchyPath string
	-- with a > in between them
    SELECT 
        Employee.Id,
        Employee.FirstName,
        Employee.LastName,
        Employee.ReportsToEmployeeId,
        EmployeeHierarchy.HierarchyLevel + 1 AS HierarchyLevel, -- Add a hierarchy level
        CAST(EmployeeHierarchy.HierarchyPath + N' > ' + Employee.FirstName + N' ' + Employee.LastName AS NVARCHAR(MAX)) AS HierarchyPath
    FROM Employee
    INNER JOIN EmployeeHierarchy
        ON Employee.ReportsToEmployeeId = EmployeeHierarchy.Id
)

SELECT  -- Select from the above temporary view of the data
    Id,
    REPLICATE(N'  ', HierarchyLevel) + FirstName + N' ' + LastName AS EmployeeName,
    HierarchyLevel,
    HierarchyPath
FROM EmployeeHierarchy
ORDER BY HierarchyPath; -- Alphabetical sort for each hierarchy level, starting at 0
