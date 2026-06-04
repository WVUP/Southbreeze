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
 - Mermaid ERD diagram created with mermerd
```mermaid
erDiagram
    dbo_Category {
        datetime2 CreatedAtUtc 
        nvarchar Description 
        int Id PK 
        bit IsActive 
        bit IsDeleted 
        nvarchar Name UK 
        varbinary Picture 
        timestamp RowVersion 
        datetime2 UpdatedAtUtc 
    }

    dbo_Customer {
        nvarchar Address 
        nvarchar City 
        nvarchar CompanyName 
        nvarchar ContactName 
        nvarchar ContactTitle 
        nvarchar Country 
        datetime2 CreatedAtUtc 
        nchar CustomerCode UK 
        nvarchar Fax 
        int Id PK 
        bit IsActive 
        bit IsDeleted 
        nvarchar Phone 
        nvarchar PostalCode 
        nvarchar Region 
        timestamp RowVersion 
        datetime2 UpdatedAtUtc 
    }

    dbo_CustomerCustomerDemographic {
        int CustomerDemographicId PK,FK 
        int CustomerId PK,FK 
    }

    dbo_CustomerDemographic {
        datetime2 CreatedAtUtc 
        nchar CustomerDemographicCode UK 
        nvarchar Description 
        int Id PK 
        bit IsActive 
        bit IsDeleted 
        timestamp RowVersion 
        datetime2 UpdatedAtUtc 
    }

    dbo_Employee {
        nvarchar Address 
        datetime2 BirthDate 
        nvarchar City 
        nvarchar Country 
        datetime2 CreatedAtUtc 
        nvarchar Extension 
        nvarchar FirstName 
        datetime2 HireDate 
        nvarchar HomePhone 
        int Id PK 
        bit IsActive 
        bit IsDeleted 
        nvarchar LastName 
        nvarchar Notes 
        varbinary Photo 
        nvarchar PhotoPath 
        nvarchar PostalCode 
        nvarchar Region 
        int ReportsToEmployeeId FK 
        timestamp RowVersion 
        nvarchar Title 
        nvarchar TitleOfCourtesy 
        datetime2 UpdatedAtUtc 
    }

    dbo_EmployeeTerritory {
        int EmployeeId PK,FK 
        int TerritoryId PK,FK 
    }

    dbo_Product {
        int CategoryId FK 
        datetime2 CreatedAtUtc 
        int Id PK 
        bit IsActive 
        bit IsDeleted 
        nvarchar Name 
        nvarchar QuantityPerUnit 
        smallint ReorderLevel 
        timestamp RowVersion 
        int SupplierId FK 
        decimal UnitPrice 
        smallint UnitsInStock 
        smallint UnitsOnOrder 
        datetime2 UpdatedAtUtc 
    }

    dbo_Region {
        datetime2 CreatedAtUtc 
        nchar Description 
        int Id PK 
        bit IsActive 
        bit IsDeleted 
        timestamp RowVersion 
        datetime2 UpdatedAtUtc 
    }

    dbo_SalesOrder {
        datetime2 CreatedAtUtc 
        int CustomerId FK 
        int EmployeeId FK 
        decimal Freight 
        int Id PK 
        bit IsDeleted 
        datetime2 OrderDate 
        datetime2 RequiredDate 
        timestamp RowVersion 
        int SalesOrderStatusId FK 
        nvarchar ShipAddress 
        nvarchar ShipCity 
        nvarchar ShipCountry 
        nvarchar ShipName 
        nvarchar ShipPostalCode 
        nvarchar ShipRegion 
        datetime2 ShippedDate 
        int ShipperId FK 
        datetime2 UpdatedAtUtc 
    }

    dbo_SalesOrderLine {
        datetime2 CreatedAtUtc 
        decimal Discount 
        int Id PK 
        bit IsDeleted 
        int ProductId FK,UK 
        smallint Quantity 
        timestamp RowVersion 
        int SalesOrderId FK,UK 
        decimal UnitPrice 
        datetime2 UpdatedAtUtc 
    }

    dbo_SalesOrderStatus {
        datetime2 CreatedAtUtc 
        nvarchar Description 
        int Id PK 
        bit IsActive 
        bit IsDeleted 
        nvarchar Name UK 
        timestamp RowVersion 
        int SortOrder 
        datetime2 UpdatedAtUtc 
    }

    dbo_Shipper {
        nvarchar CompanyName 
        datetime2 CreatedAtUtc 
        int Id PK 
        bit IsActive 
        bit IsDeleted 
        nvarchar Phone 
        timestamp RowVersion 
        datetime2 UpdatedAtUtc 
    }

    dbo_Supplier {
        nvarchar Address 
        nvarchar City 
        nvarchar CompanyName 
        nvarchar ContactName 
        nvarchar ContactTitle 
        nvarchar Country 
        datetime2 CreatedAtUtc 
        nvarchar Fax 
        nvarchar HomePage 
        int Id PK 
        bit IsActive 
        bit IsDeleted 
        nvarchar Phone 
        nvarchar PostalCode 
        nvarchar Region 
        timestamp RowVersion 
        datetime2 UpdatedAtUtc 
    }

    dbo_Territory {
        datetime2 CreatedAtUtc 
        nchar Description 
        int Id PK 
        bit IsActive 
        bit IsDeleted 
        int RegionId FK 
        timestamp RowVersion 
        nvarchar TerritoryCode UK 
        datetime2 UpdatedAtUtc 
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
