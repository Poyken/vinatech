CREATE TABLE [dbo].[STB_ProductStockInfoUpload_backup] (
    [ProductStockNo] VARCHAR(20) NOT NULL DEFAULT ,
    [CompanyCode] VARCHAR(20) NULL DEFAULT ,
    [WorkCenterCode] VARCHAR(20) NULL DEFAULT ,
    [MaterialCode] VARCHAR(20) NULL DEFAULT ,
    [Barcode] VARCHAR(20) NULL DEFAULT ,
    [PackingID] VARCHAR(20) NULL DEFAULT ,
    [MaterialWarehouseCode] VARCHAR(20) NULL DEFAULT ,
    [MaterialLocationCode] VARCHAR(20) NULL DEFAULT ,
    [PaletteNo] NVARCHAR(20) NULL DEFAULT ,
    [StockQty] NUMERIC(20,2) NULL DEFAULT ,
    [ManufacturingUnitPrice] NUMERIC(20,5) NULL DEFAULT ,
    [StockPrice] NUMERIC(38,6) NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

