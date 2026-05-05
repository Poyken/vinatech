CREATE TABLE [dbo].[STB_SparePartStockInfo] (
    [SPWarehouseCode] VARCHAR(20) NOT NULL DEFAULT ,
    [SPLocationCode] VARCHAR(20) NOT NULL DEFAULT ,
    [SparePartCode] VARCHAR(20) NOT NULL DEFAULT ,
    [CurrentStockQty] NUMERIC(20,5) NULL DEFAULT ,
    CONSTRAINT [PK_STB_SparePartStockInfo] PRIMARY KEY CLUSTERED ([SPWarehouseCode], [SPLocationCode], [SparePartCode])
);
GO

