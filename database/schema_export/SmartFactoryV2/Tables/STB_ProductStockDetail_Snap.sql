CREATE TABLE [dbo].[STB_ProductStockDetail_Snap] (
    [CompanyCode] VARCHAR(20) NOT NULL DEFAULT ,
    [MaterialCode] VARCHAR(20) NOT NULL DEFAULT ,
    [MaterialWarehouseCode] VARCHAR(3) NOT NULL DEFAULT ,
    [Barcode] VARCHAR(20) NOT NULL DEFAULT ,
    [BarcodeStockQty] NUMERIC(20,2) NOT NULL DEFAULT ,
    [Remark] NVARCHAR(MAX) NULL DEFAULT ,
    [ProductionDate] VARCHAR(10) NULL DEFAULT ,
    [RefreshedAt] DATETIME NOT NULL DEFAULT (getdate()),
    CONSTRAINT [PK_STB_ProductStockDetail_Snap] PRIMARY KEY CLUSTERED ([CompanyCode], [MaterialCode], [Barcode])
);
GO

