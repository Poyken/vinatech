CREATE TABLE [dbo].[STB_VNSparePartStockInfo_050224] (
    [WorkCenterCode] VARCHAR(20) NOT NULL DEFAULT ,
    [SPWarehouseCode] VARCHAR(20) NOT NULL DEFAULT ,
    [SPLocationCode] VARCHAR(20) NOT NULL DEFAULT ,
    [SparePartCode] VARCHAR(20) NOT NULL DEFAULT ,
    [CurrentStockQty] NUMERIC(20,5) NULL DEFAULT 
);
GO

