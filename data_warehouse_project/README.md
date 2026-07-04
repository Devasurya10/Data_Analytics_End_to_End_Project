# data_warehouse_project

## 📖 Project Overview:

This project involves

1. Data Architecture: Designing a Modern Data Warehouse Using Medallion Architecture Bronze, Silver, and Gold layers.  
2. ETL Pipelines: Extracting, transforming, and loading data from source systems into the warehouse.  
3. Data Modeling: Developing fact and dimension tables optimized for analytical queries.  
4. Analytics & Reporting: Creating SQL-based reports and dashboards for actionable insights.  

## 🏗️ Project Architecture:

The project is organized into three data layers:  

1. Bronze Layer: Stores raw data as-is from the source systems. Data is ingested from CSV Files into SQL Server Database.  
2. Silver Layer: This layer includes data cleansing, standardization, and normalization processes to prepare data for analysis.  
3. Gold Layer: Houses business-ready data modeled into a star schema required for reporting and analytics.  
               Objects in the Gold layer include:  
                                                . DimCustomer   
                                                . DimProduct  
                                                . FactSales (implemented as a SQL View)  

The FactSales view is the primary analytical dataset and is used as the source for building the next Exploratory Data Analysis (EDA) project layer.  

## 🛠️ Datasets:  

The datasets folder contains the source files used to build the warehouse  

1. source_crm:    
2. source_erp:    

## 📂 REPOSITORY STRUCTURE    
```
 data-warehouse-project/  
│    
├── datasets/                             
│   ├──source_crm                       # Raw datasets used for the project (ERP and CRM data)  
|   ├──source_erp  
|  
|  
├── docs/                               # Project documentation and architecture details  
│   ├── data_catalog.md                 # Catalog of datasets, including field descriptions and metadata  
│  
├── scripts/                            # SQL scripts for ETL and transformations  
│   ├── bronze/                         # Scripts for extracting and loading raw data  
│   ├── silver/                         # Scripts for cleaning and transforming data   
│   ├── gold/                           # Scripts for creating analytical models  
│  
│  
├── README.md                           # Project overview and instructions  
├── LICENSE                             # License information for the repository  
```  
  
```Next Step: The Gold layer created in this project is used for the "EDA Project", where the data is explored using SQL.  ```
