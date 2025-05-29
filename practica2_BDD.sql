create database practicaPE
use practicaPE

select * into SalesOrderHeader
from AdventureWorks2022.sales.SalesOrderHeader

select * into SalesOrderDetail
from AdventureWorks2022.sales.SalesOrderDetail

select * into Customer
from AdventureWorks2022.sales.Customer

select * into SalesTerritory
from AdventureWorks2022.sales.SalesTerritory

select * into Product
from AdventureWorks2022.Production.Product

select * into ProductCategory
from AdventureWorks2022.Production.ProductCategory

select * into ProductSubcategory
from AdventureWorks2022.Production.ProductSubcategory

select BusinessEntityID, FirstName, LastName into Person
from AdventureWorks2022.Person.Person

-------------------------------------------------------------------------
-- PRACTICA 2. PUNTO 1
USE AdventureWorks2022;
GO
WITH ProductoVentas AS (
    SELECT 
        c.Name AS Categoria,
        p.Name AS Producto,
        SUM(sod.OrderQty) AS TotalVendido
    FROM Sales.SalesOrderDetail sod
    JOIN Production.Product p ON sod.ProductID = p.ProductID
    JOIN Production.ProductSubcategory psc ON p.ProductSubcategoryID = psc.ProductSubcategoryID
    JOIN Production.ProductCategory c ON psc.ProductCategoryID = c.ProductCategoryID
    GROUP BY c.Name, p.Name
),
MaxVentasPorCategoria AS (
    SELECT 
        Categoria,
        MAX(TotalVendido) AS MaxVendido
    FROM ProductoVentas
    GROUP BY Categoria
)
SELECT 
    pv.Categoria,
    pv.Producto,
    pv.TotalVendido
FROM ProductoVentas pv
JOIN MaxVentasPorCategoria mv
    ON pv.Categoria = mv.Categoria AND pv.TotalVendido = mv.MaxVendido
ORDER BY pv.Categoria;


USE practicaPE;
GO
CREATE NONCLUSTERED INDEX SOD_CoveringQuery
ON SalesOrderDetail(ProductID)
INCLUDE (OrderQty);
with ProductoVentas as (
    select 
        c.Name as Categoria,
        p.Name as Producto,
        SUM(sod.OrderQty) as TotalVendido
    from SalesOrderDetail sod
    join Product p on sod.ProductID = p.ProductID
    join ProductSubcategory psc on p.ProductSubcategoryID = psc.ProductSubcategoryID
    join ProductCategory c on psc.ProductCategoryID = c.ProductCategoryID
    group by c.Name, p.Name
),
MaxVentasPorCategoria as (
    select 
        Categoria,
        max(TotalVendido) as MaxVendido
    from ProductoVentas
    group by Categoria
)
select 
    pv.Categoria,
    pv.Producto,
    pv.TotalVendido
from ProductoVentas pv
join MaxVentasPorCategoria mv
    on pv.Categoria = mv.Categoria AND pv.TotalVendido = mv.MaxVendido
order by pv.Categoria;

-------------------------------------------------------------------------
-- PRACTICA 2. PUNTO 2
WITH Customer_Orders AS (
    SELECT 
        soh.SalesOrderID, 
        c.CustomerID, 
        soh.TerritoryID, 
        p.FirstName,  
        p.LastName
    FROM SalesOrderHeader soh
    JOIN Customer c ON soh.CustomerID = c.CustomerID
    JOIN Person p ON c.PersonID = p.BusinessEntityID
),
OrdenesPorCliente AS (
    SELECT 
        TerritoryID, 
        CustomerID, 
        FirstName,  
        LastName, 
        COUNT(*) AS Orders
    FROM Customer_Orders
    GROUP BY TerritoryID, CustomerID, FirstName, LastName
),
MaxOrdenesPorTerritorio AS (
    SELECT 
        TerritoryID, 
        MAX(Orders) AS MaxOrders
    FROM OrdenesPorCliente
    GROUP BY TerritoryID
)
SELECT 
    o.TerritoryID, 
    o.FirstName,  
    o.LastName, 
    o.Orders
FROM OrdenesPorCliente o
JOIN MaxOrdenesPorTerritorio m
    ON o.TerritoryID = m.TerritoryID AND o.Orders = m.MaxOrders
ORDER BY o.TerritoryID;



WITH Customer_Orders AS (
    SELECT 
        soh.SalesOrderID, 
        c.CustomerID, 
        soh.TerritoryID, 
        p.FirstName,  
        p.LastName
    FROM SalesOrderHeader soh
    JOIN Customer c ON soh.CustomerID = c.CustomerID
    JOIN Person p ON c.PersonID = p.BusinessEntityID
),
OrdenesPorCliente AS (
    SELECT 
        TerritoryID, 
        CustomerID, 
        FirstName,  
        LastName, 
        COUNT(*) AS Orders
    FROM Customer_Orders
    GROUP BY TerritoryID, CustomerID, FirstName, LastName
),
MaxOrdenesPorTerritorio AS (
    SELECT 
        TerritoryID, 
        MAX(Orders) AS MaxOrders
    FROM OrdenesPorCliente
    GROUP BY TerritoryID
)
SELECT 
    o.TerritoryID, 
    o.FirstName,  
    o.LastName, 
    o.Orders
FROM OrdenesPorCliente o
JOIN MaxOrdenesPorTerritorio m
    ON o.TerritoryID = m.TerritoryID AND o.Orders = m.MaxOrders
ORDER BY o.TerritoryID;

WITH Customer_Orders AS (
    SELECT 
        soh.SalesOrderID, 
        c.CustomerID, 
        soh.TerritoryID, 
        p.FirstName,  
        p.LastName
    FROM SalesOrderHeader soh
    JOIN Customer c ON soh.CustomerID = c.CustomerID
    JOIN Person p ON c.PersonID = p.BusinessEntityID
),
OrdenesPorCliente AS (
    SELECT 
        TerritoryID, 
        CustomerID, 
        FirstName,  
        LastName, 
        COUNT(*) AS Orders
    FROM Customer_Orders
    GROUP BY TerritoryID, CustomerID, FirstName, LastName
),
MaxOrdenesPorTerritorio AS (
    SELECT 
        TerritoryID, 
        MAX(Orders) AS MaxOrders
    FROM OrdenesPorCliente
    GROUP BY TerritoryID
)
SELECT 
    o.TerritoryID, 
    o.FirstName,  
    o.LastName, 
    o.Orders
FROM OrdenesPorCliente o
JOIN MaxOrdenesPorTerritorio m
    ON o.TerritoryID = m.TerritoryID AND o.Orders = m.MaxOrders
ORDER BY o.TerritoryID;

WITH Customer_Orders AS (
    SELECT 
        soh.SalesOrderID, 
        c.CustomerID, 
        soh.TerritoryID, 
        p.FirstName,  
        p.LastName
    FROM SalesOrderHeader soh
    JOIN Customer c ON soh.CustomerID = c.CustomerID
    JOIN Person p ON c.PersonID = p.BusinessEntityID
),
OrdenesPorCliente AS (
    SELECT 
        TerritoryID, 
        CustomerID, 
        FirstName,  
        LastName, 
        COUNT(*) AS Orders
    FROM Customer_Orders
    GROUP BY TerritoryID, CustomerID, FirstName, LastName
),
MaxOrdenesPorTerritorio AS (
    SELECT 
        TerritoryID, 
        MAX(Orders) AS MaxOrders
    FROM OrdenesPorCliente
    GROUP BY TerritoryID
)
SELECT 
    o.TerritoryID, 
    o.FirstName,  
    o.LastName, 
    o.Orders
FROM OrdenesPorCliente o
JOIN MaxOrdenesPorTerritorio m
    ON o.TerritoryID = m.TerritoryID AND o.Orders = m.MaxOrders
ORDER BY o.TerritoryID;

-------------------------------------------------------------------------
-- PRACTICA 2. PUNTO 3
USE AdventureWorks2022;
GO
SELECT DISTINCT Salesorderid
FROM Sales.SalesOrderDetail AS OD	
WHERE NOT EXISTS
				(
					SELECT *
					FROM (SELECT productid
					from Sales.SalesOrderDetail 
					where salesorderid=43676) as P
					WHERE NOT EXISTS
								(
									SELECT *
									FROM Sales.SalesOrderDetail  AS OD2
									WHERE OD.salesorderid = OD2.salesorderid
									AND (OD2.productid = P.productid)
								)
				);

USE practicaPE;
GO
CREATE NONCLUSTERED INDEX IDX_SalesOrderDetail_SalesOrder_Product
ON SalesOrderDetail (SalesOrderID, ProductID);
SELECT DISTINCT Salesorderid
FROM SalesOrderDetail AS OD	
WHERE NOT EXISTS
				(
					SELECT *
					FROM (SELECT productid
					from SalesOrderDetail 
					where salesorderid=43676) as P
					WHERE NOT EXISTS
								(
									SELECT *
									FROM SalesOrderDetail  AS OD2
									WHERE OD.salesorderid = OD2.salesorderid
									AND (OD2.productid = P.productid)
								)
				);