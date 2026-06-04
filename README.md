# Southbreeze
This project contains a modified version of the Microsoft Northwind sample database.

The original Northwind database was created by Microsoft and has been substantially modified for instructional use, including:
- Renamed tables and columns
- New primary key strategy
- New lookup tables
- Additional auditing fields
- Additional constraints
- New example queries

See Microsoft's original Northwind sample database for historical reference.

## Setup
In the scripts folder, **look for the subfolder for your particular DBMS**.

Get the _southbreeze_database.sql_ script
 - This script will create the tables and seed initial data in the table

Execute this script on an empty database 

## Usage
In the scripts folder, again **look for the subfolder for your particular DBMS**.

Get the _example_queries.sql_ script and open it in a text editor/viewer such as Notepad++ if you are on Windows

Read through the file, the comments describe what each query does.
 - **Note**: None of them modify the data in the database, so you can run them as many times as you want

These example ad-hoc queries demonstrate relational database operations such as:
 - Cartesian product
 - Integrity constraints
 - Project
   - This is really just selecting columns by name to get a logical view of the data independent of the physical view
 - Several examples of queries that would answer common business questions, including:
         - Which products are currently active and not deleted
         - Which orders have not shipped yet
         - Which customers are located in Germany
 - Join operations, including:
         - Inner/equi join (following a foreign key)
         - Theta join (joining data using a comparison other than equals)
         - Left/Right outer join
         - Full outer join
         - Left/Right semi-join
         - Natural join
 - Relational Division
 - Arithmetic operations
   - Counting the number of records
 - Nested operations
 - Grouping of results
 - Sorting of results
 - Set operations
   - Union - Combines results and removes duplicates
   - Union All - Combines results and keeps duplicates
   - Intersect - only values that appear in both result sets
   - Except - difference operations
   -  Views
     -  Creating
     -  Querying
 -  Recursive querying of a table for:
    -  Direct relationships
    -  Full hierarchical demonstration

## Southbreeze design
 - Mermaid ERD diagram created with mermerd.
```mermaid
erDiagram
    dbo_Category {
        int Id PK 
        bit IsActive 
        bit IsDeleted
        timestamp RowVersion 
        datetime2 CreatedAtUtc
        datetime2 UpdatedAtUtc 
        nvarchar Description 
        nvarchar Name UK 
        varbinary Picture 
    }

    dbo_Customer {
        int Id PK 
        bit IsActive 
        bit IsDeleted
        timestamp RowVersion 
        datetime2 CreatedAtUtc
        datetime2 UpdatedAtUtc
        nchar CustomerCode UK 
        nvarchar CompanyName 
        nvarchar ContactName 
        nvarchar ContactTitle 
        nvarchar Address 
        nvarchar City
        nvarchar PostalCode 
        nvarchar Region 
        nvarchar Country 
        nvarchar Fax  
        nvarchar Phone 
    }

    dbo_CustomerCustomerDemographic {
        int CustomerDemographicId PK,FK 
        int CustomerId PK,FK 
    }

    dbo_CustomerDemographic {
        int Id PK 
        bit IsActive 
        bit IsDeleted
        timestamp RowVersion
        datetime2 CreatedAtUtc
        datetime2 UpdatedAtUtc 
        nchar CustomerDemographicCode UK 
        nvarchar Description 
    }

    dbo_Employee {
        int Id PK
        int ReportsToEmployeeId FK 
        bit IsActive 
        bit IsDeleted
        timestamp RowVersion 
        datetime2 CreatedAtUtc 
        datetime2 UpdatedAtUtc 
        datetime2 BirthDate 
        datetime2 HireDate
        nvarchar Title 
        nvarchar TitleOfCourtesy 
        nvarchar FirstName 
        nvarchar LastName 
        nvarchar Extension 
        nvarchar Address 
        nvarchar City 
        nvarchar Region 
        nvarchar PostalCode 
        nvarchar Country 
        nvarchar HomePhone 
        nvarchar Notes 
        varbinary Photo 
        nvarchar PhotoPath 
    }

    dbo_EmployeeTerritory {
        int EmployeeId PK,FK 
        int TerritoryId PK,FK 
    }

    dbo_Product {
        int Id PK
        int CategoryId FK 
        int SupplierId FK 
        bit IsActive 
        bit IsDeleted 
        timestamp RowVersion 
        datetime2 CreatedAtUtc 
        datetime2 UpdatedAtUtc 
        nvarchar Name 
        nvarchar QuantityPerUnit 
        smallint ReorderLevel 
        decimal UnitPrice 
        smallint UnitsInStock 
        smallint UnitsOnOrder 
    }

    dbo_Region {
        int Id PK 
        bit IsActive 
        bit IsDeleted 
        timestamp RowVersion 
        datetime2 CreatedAtUtc 
        datetime2 UpdatedAtUtc 
        nchar Description 
    }

    dbo_SalesOrder {
        int Id PK 
        int SalesOrderStatusId FK 
        int CustomerId FK 
        int EmployeeId FK 
        int ShipperId FK 
        bit IsDeleted 
        timestamp RowVersion 
        datetime2 CreatedAtUtc 
        datetime2 UpdatedAtUtc 
        datetime2 OrderDate 
        datetime2 RequiredDate
        datetime2 ShippedDate 
        decimal Freight 
        nvarchar ShipName 
        nvarchar ShipAddress 
        nvarchar ShipCity 
        nvarchar ShipCountry 
        nvarchar ShipPostalCode 
        nvarchar ShipRegion 
    }

    dbo_SalesOrderLine {
        int Id PK
        int SalesOrderId FK,UK 
        int ProductId FK,UK 
        bit IsDeleted 
        timestamp RowVersion 
        datetime2 CreatedAtUtc 
        datetime2 UpdatedAtUtc
        decimal Discount 
        smallint Quantity 
        decimal UnitPrice 
    }

    dbo_SalesOrderStatus {
        int Id PK 
        bit IsActive 
        bit IsDeleted 
        timestamp RowVersion 
        datetime2 CreatedAtUtc 
        datetime2 UpdatedAtUtc
        nvarchar Name UK 
        nvarchar Description 
        int SortOrder 
    }

    dbo_Shipper {
        int Id PK 
        bit IsActive 
        bit IsDeleted 
        timestamp RowVersion 
        datetime2 CreatedAtUtc 
        datetime2 UpdatedAtUtc 
        nvarchar CompanyName 
        nvarchar Phone 
    }

    dbo_Supplier {
        int Id PK 
        bit IsActive 
        bit IsDeleted 
        timestamp RowVersion 
        datetime2 CreatedAtUtc 
        datetime2 UpdatedAtUtc 
        nvarchar CompanyName 
        nvarchar ContactTitle 
        nvarchar ContactName 
        nvarchar HomePage 
        nvarchar Phone 
        nvarchar Fax 
        nvarchar Address 
        nvarchar City
        nvarchar Region 
        nvarchar Country 
        nvarchar PostalCode 
    }

    dbo_Territory {
        int Id PK
        int RegionId FK 
        bit IsActive 
        bit IsDeleted 
        timestamp RowVersion 
        datetime2 CreatedAtUtc 
        datetime2 UpdatedAtUtc
        nvarchar TerritoryCode UK 
        nchar Description 
    }

    dbo_Product }o--|| dbo_Category : "CategoryId"
    dbo_CustomerCustomerDemographic }o--|| dbo_Customer : "CustomerId"
    dbo_SalesOrder }o--|| dbo_Customer : "CustomerId"
    dbo_CustomerCustomerDemographic }o--|| dbo_CustomerDemographic : "CustomerDemographicId"
    dbo_Employee }o--|| dbo_Employee : "ReportsToEmployeeId"
    dbo_EmployeeTerritory }o--|| dbo_Employee : "EmployeeId"
    dbo_SalesOrder }o--|| dbo_Employee : "EmployeeId"
    dbo_EmployeeTerritory }o--|| dbo_Territory : "TerritoryId"
    dbo_Product }o--|| dbo_Supplier : "SupplierId"
    dbo_SalesOrderLine }o--|| dbo_Product : "ProductId"
    dbo_Territory }o--|| dbo_Region : "RegionId"
    dbo_SalesOrder }o--|| dbo_SalesOrderStatus : "SalesOrderStatusId"
    dbo_SalesOrder }o--|| dbo_Shipper : "ShipperId"
    dbo_SalesOrderLine }o--|| dbo_SalesOrder : "SalesOrderId"
```
