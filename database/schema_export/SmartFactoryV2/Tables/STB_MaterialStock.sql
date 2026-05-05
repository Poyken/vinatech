CREATE TABLE [dbo].[STB_MaterialStock] (
    [MaterialStockNo] BIGINT NOT NULL DEFAULT ,
    [CompanyCode] VARCHAR(20) NULL DEFAULT ,
    [WorkCenterCode] VARCHAR(20) NULL DEFAULT ,
    [MaterialWarehouseCode] VARCHAR(20) NULL DEFAULT ,
    [MaterialLocationCode] VARCHAR(20) NULL DEFAULT ,
    [MaterialCode] VARCHAR(50) NULL DEFAULT ,
    [MaterialStockAttribute] VARCHAR(20) NULL DEFAULT ,
    [StockAttrib1] VARCHAR(20) NULL DEFAULT ,
    [StockAttrib2] VARCHAR(20) NULL DEFAULT ,
    [StockAttrib3] VARCHAR(20) NULL DEFAULT ,
    [StockQty] NUMERIC(20,5) NULL DEFAULT ,
    [PickingAssignQty] NUMERIC(20,5) NULL DEFAULT ,
    [PickingQty] NUMERIC(20,5) NULL DEFAULT 
);
GO

