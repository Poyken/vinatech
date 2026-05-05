CREATE TABLE [dbo].[STB_ShipmentInfoTempForERP] (
    [ShipmentInfoNo] BIGINT IDENTITY(1,1) NOT NULL DEFAULT ,
    [MaterialWarehouseName] NVARCHAR(100) NULL DEFAULT ,
    [ShipmentNo] VARCHAR(30) NULL DEFAULT ,
    [ShipmentSerNo] INT NULL DEFAULT ,
    [ShipmentDate] DATE NULL DEFAULT ,
    [ShipmentClassName] NVARCHAR(20) NULL DEFAULT ,
    [CustomerName] NVARCHAR(100) NULL DEFAULT ,
    [MaterialCode] VARCHAR(20) NULL DEFAULT ,
    [MaterialName] NVARCHAR(200) NULL DEFAULT ,
    [MaterialSpec] NVARCHAR(200) NULL DEFAULT ,
    [MaterialSize] NVARCHAR(100) NULL DEFAULT ,
    [MaterialQty] NUMERIC(10,2) NULL DEFAULT ,
    [MaterialUnitCode] VARCHAR(20) NULL DEFAULT ,
    [MaterialUnitPrice] NUMERIC(20,5) NULL DEFAULT ,
    [MaterialTotPrice] NUMERIC(20,5) NULL DEFAULT ,
    [CurrencyCode] VARCHAR(10) NULL DEFAULT ,
    [CurrencyRate] NUMERIC(20,5) NULL DEFAULT ,
    [ConvertPrice] NUMERIC(20,5) NULL DEFAULT ,
    [StockUnitPrice] NUMERIC(20,5) NULL DEFAULT ,
    [StockTotPrice] NUMERIC(20,5) NULL DEFAULT ,
    [Margin] NUMERIC(20,5) NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

