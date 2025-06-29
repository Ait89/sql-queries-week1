USE AdventureWorks2019;
SELECT * FROM Sales.Customer;
SELECT c.CustomerID, s.Name AS CompanyName
FROM Sales.Customer c
JOIN Sales.Store s ON c.StoreID = s.BusinessEntityID
WHERE s.Name LIKE '%N';
SELECT * 
FROM Sales.vIndividualCustomer
WHERE City IN ('Berlin', 'London');
SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'Sales';

SELECT c.CustomerID, p.FirstName, p.LastName, cr.Name AS CountryRegionName
FROM Sales.Customer c
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
JOIN Person.BusinessEntityAddress bea ON p.BusinessEntityID = bea.BusinessEntityID
JOIN Person.Address a ON bea.AddressID = a.AddressID
JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
JOIN Person.CountryRegion cr ON sp.CountryRegionCode = cr.CountryRegionCode
WHERE cr.Name IN ('United Kingdom', 'United States')
  AND c.PersonID IS NOT NULL;
SELECT * 
FROM Production.Product
ORDER BY Name;
SELECT DISTINCT c.CustomerID, p.FirstName, p.LastName
FROM Sales.Customer c
JOIN Sales.SalesOrderHeader o ON c.CustomerID = o.CustomerID
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID;
SELECT DISTINCT p.FirstName, p.LastName, a.City
FROM Sales.SalesOrderHeader oh
JOIN Sales.SalesOrderDetail od ON oh.SalesOrderID = od.SalesOrderID
JOIN Production.Product pr ON od.ProductID = pr.ProductID
JOIN Sales.Customer c ON oh.CustomerID = c.CustomerID
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
JOIN Person.Address a ON oh.ShipToAddressID = a.AddressID
WHERE a.City = 'London' AND pr.Name = 'Chai';

SELECT p.FirstName, p.LastName
FROM Sales.Customer c
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
WHERE c.CustomerID NOT IN (
    SELECT DISTINCT CustomerID FROM Sales.SalesOrderHeader
);
SELECT DISTINCT p.FirstName, p.LastName
FROM Sales.SalesOrderHeader oh
JOIN Sales.SalesOrderDetail od ON oh.SalesOrderID = od.SalesOrderID
JOIN Production.Product pr ON od.ProductID = pr.ProductID
JOIN Sales.Customer c ON oh.CustomerID = c.CustomerID
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
WHERE pr.Name = 'Tofu';

SELECT TOP 1 * 
FROM Sales.SalesOrderHeader
ORDER BY OrderDate ASC;

SELECT TOP 1 OrderDate, TotalDue 
FROM Sales.SalesOrderHeader
ORDER BY TotalDue DESC;

SELECT SalesOrderID, AVG(OrderQty) AS AvgQuantity
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID;

SELECT SalesOrderID,
       MIN(OrderQty) AS MinQty,
       MAX(OrderQty) AS MaxQty
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID;

SELECT 
    mgr.BusinessEntityID AS ManagerID,
    p.FirstName + ' ' + p.LastName AS ManagerName,
    COUNT(emp.BusinessEntityID) AS EmployeeCount
FROM HumanResources.Employee emp
JOIN HumanResources.Employee mgr 
    ON emp.OrganizationNode.GetAncestor(1) = mgr.OrganizationNode
JOIN Person.Person p 
    ON mgr.BusinessEntityID = p.BusinessEntityID
GROUP BY mgr.BusinessEntityID, p.FirstName, p.LastName;


SELECT SalesOrderID, SUM(OrderQty) AS TotalQuantity
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID
HAVING SUM(OrderQty) > 300;


-- 17. List of all orders placed on or after 1996/12/31
SELECT * FROM Sales.SalesOrderHeader
WHERE OrderDate >= '1996-12-31';

SELECT soh.*
FROM Sales.SalesOrderHeader soh
JOIN Person.Address a ON soh.ShipToAddressID = a.AddressID
JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
JOIN Person.CountryRegion cr ON sp.CountryRegionCode = cr.CountryRegionCode
WHERE cr.Name = 'Canada';

SELECT * FROM Sales.SalesOrderHeader
WHERE TotalDue > 200;

SELECT cr.Name AS Country, SUM(soh.TotalDue) AS TotalSales
FROM Sales.SalesOrderHeader soh
JOIN Person.Address a ON soh.ShipToAddressID = a.AddressID
JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
JOIN Person.CountryRegion cr ON sp.CountryRegionCode = cr.CountryRegionCode
GROUP BY cr.Name;


SELECT p.FirstName + ' ' + p.LastName AS ContactName, COUNT(soh.SalesOrderID) AS OrderCount
FROM Sales.Customer c
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
GROUP BY p.FirstName, p.LastName;


SELECT p.FirstName + ' ' + p.LastName AS ContactName, COUNT(soh.SalesOrderID) AS OrderCount
FROM Sales.Customer c
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
GROUP BY p.FirstName, p.LastName
HAVING COUNT(soh.SalesOrderID) > 3;

-- 23. List of discontinued products ordered between 1997-01-01 and 1998-01-01
SELECT DISTINCT pr.Name
FROM Production.Product pr
JOIN Sales.SalesOrderDetail sod ON pr.ProductID = sod.ProductID
JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
WHERE pr.DiscontinuedDate IS NOT NULL
AND soh.OrderDate BETWEEN '1997-01-01' AND '1998-01-01';

-- 24. Employee first name, last name, supervisor's first name, last name
SELECT e1.BusinessEntityID, p1.FirstName, p1.LastName,
       p2.FirstName AS SupervisorFirstName, p2.LastName AS SupervisorLastName
FROM HumanResources.Employee e1
JOIN Person.Person p1 ON e1.BusinessEntityID = p1.BusinessEntityID
JOIN HumanResources.Employee e2 ON e1.OrganizationNode.GetAncestor(1) = e2.OrganizationNode
JOIN Person.Person p2 ON e2.BusinessEntityID = p2.BusinessEntityID;

-- 25. List of Employees and total sale conducted by employee
SELECT soh.SalesPersonID, p.FirstName, p.LastName, SUM(soh.TotalDue) AS TotalSales
FROM Sales.SalesOrderHeader soh
JOIN HumanResources.Employee e ON soh.SalesPersonID = e.BusinessEntityID
JOIN Person.Person p ON e.BusinessEntityID = p.BusinessEntityID
GROUP BY soh.SalesPersonID, p.FirstName, p.LastName;

-- 26. List of employees whose FirstName contains character 'a'
SELECT FirstName, LastName
FROM Person.Person
WHERE FirstName LIKE '%a%';

-- 27. List of managers with more than four direct reports
SELECT e2.BusinessEntityID AS ManagerID, p.FirstName, p.LastName, COUNT(e1.BusinessEntityID) AS ReportCount
FROM HumanResources.Employee e1
JOIN HumanResources.Employee e2 ON e1.OrganizationNode.GetAncestor(1) = e2.OrganizationNode
JOIN Person.Person p ON e2.BusinessEntityID = p.BusinessEntityID
GROUP BY e2.BusinessEntityID, p.FirstName, p.LastName
HAVING COUNT(e1.BusinessEntityID) > 4;

-- 28. List of Orders and Product Names
SELECT soh.SalesOrderID, pr.Name AS ProductName
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product pr ON sod.ProductID = pr.ProductID;

-- 29. Orders placed by the best customer (most money spent)
SELECT TOP 1 c.CustomerID, SUM(soh.TotalDue) AS TotalSpent
FROM Sales.Customer c
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
GROUP BY c.CustomerID
ORDER BY TotalSpent DESC;

-- 30. Orders by customers without a fax number
SELECT soh.*
FROM Sales.SalesOrderHeader soh
JOIN Sales.Customer c ON soh.CustomerID = c.CustomerID
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
WHERE p.BusinessEntityID NOT IN (
    SELECT BusinessEntityID 
    FROM Person.PersonPhone
    WHERE PhoneNumberTypeID = 3  -- 3 is usually Fax in AW schema
);


-- 31. Postal codes where Tofu was shipped
SELECT DISTINCT a.PostalCode
FROM Sales.SalesOrderDetail sod
JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
JOIN Production.Product p ON sod.ProductID = p.ProductID
JOIN Person.Address a ON soh.ShipToAddressID = a.AddressID
WHERE p.Name = 'Tofu';

-- 32. Products shipped to France
SELECT DISTINCT pr.Name
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product pr ON sod.ProductID = pr.ProductID
JOIN Person.Address a ON soh.ShipToAddressID = a.AddressID
JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
JOIN Person.CountryRegion cr ON sp.CountryRegionCode = cr.CountryRegionCode
WHERE cr.Name = 'France';


-- 33. Product names and categories for supplier 'Specialty Biscuits, Ltd.'
SELECT pr.Name, pc.Name AS CategoryName
FROM Production.Product pr
JOIN Production.ProductSubcategory psc ON pr.ProductSubcategoryID = psc.ProductSubcategoryID
JOIN Production.ProductCategory pc ON psc.ProductCategoryID = pc.ProductCategoryID
JOIN Purchasing.ProductVendor pv ON pr.ProductID = pv.ProductID
JOIN Purchasing.Vendor v ON pv.BusinessEntityID = v.BusinessEntityID
WHERE v.Name = 'Specialty Biscuits, Ltd.';

-- 34. Products never ordered
SELECT pr.Name
FROM Production.Product pr
WHERE pr.ProductID NOT IN (
  SELECT DISTINCT ProductID FROM Sales.SalesOrderDetail
);

-- 35. Products where stock < 10 and units on order = 0
SELECT p.Name
FROM Production.ProductInventory pi
JOIN Production.Product p ON pi.ProductID = p.ProductID
WHERE pi.Quantity < 10;


-- 36. Top 10 countries by sales
SELECT TOP 10 cr.Name AS Country, SUM(soh.TotalDue) AS TotalSales
FROM Sales.SalesOrderHeader soh
JOIN Person.Address a ON soh.ShipToAddressID = a.AddressID
JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
JOIN Person.CountryRegion cr ON sp.CountryRegionCode = cr.CountryRegionCode
GROUP BY cr.Name
ORDER BY TotalSales DESC;


-- 37. Number of orders each employee took for customers with CustomerIDs between 'A' and 'AO'
SELECT soh.SalesPersonID, COUNT(*) AS OrderCount
FROM Sales.SalesOrderHeader soh
JOIN Sales.Customer c ON soh.CustomerID = c.CustomerID
WHERE CAST(c.CustomerID AS NVARCHAR) BETWEEN 'A' AND 'AO'
GROUP BY soh.SalesPersonID;

-- 38. Order date of most expensive order
SELECT TOP 1 OrderDate
FROM Sales.SalesOrderHeader
ORDER BY TotalDue DESC;

-- 39. Product name and total revenue from that product
SELECT p.Name, SUM(sod.LineTotal) AS Revenue
FROM Sales.SalesOrderDetail sod
JOIN Production.Product p ON sod.ProductID = p.ProductID
GROUP BY p.Name;

-- 40. Supplier name and number of products offered
SELECT v.Name, COUNT(pv.ProductID) AS ProductCount
FROM Purchasing.Vendor v
JOIN Purchasing.ProductVendor pv ON v.BusinessEntityID = pv.BusinessEntityID
GROUP BY v.Name;

-- 41. Top 10 customers based on business
SELECT TOP 10 c.CustomerID, SUM(soh.TotalDue) AS TotalSpent
FROM Sales.Customer c
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
GROUP BY c.CustomerID
ORDER BY TotalSpent DESC;

-- 42. Total revenue of the company
SELECT SUM(TotalDue) AS TotalRevenue
FROM Sales.SalesOrderHeader;
