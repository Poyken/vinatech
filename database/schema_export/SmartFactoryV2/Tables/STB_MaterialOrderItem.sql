CREATE TABLE [dbo].[STB_MaterialOrderItem] (
    [MaterialOrderItemNo] VARCHAR(20) NOT NULL DEFAULT ,
    [MaterialOrderNo] VARCHAR(20) NOT NULL DEFAULT ,
    [MaterialCode] VARCHAR(50) NULL DEFAULT ,
    [MaterialStockAttribute] VARCHAR(20) NULL DEFAULT ,
    [MaterialAttribute] VARCHAR(20) NULL DEFAULT ,
    [StockAttrib1] VARCHAR(20) NULL DEFAULT ,
    [StockAttrib2] VARCHAR(20) NULL DEFAULT ,
    [StockAttrib3] VARCHAR(20) NULL DEFAULT ,
    [MaterialOrderQty] NUMERIC(20,5) NULL DEFAULT ,
    [MaterialOrderUnitPriceQty] NUMERIC(20,5) NULL DEFAULT ,
    [MaterialOrderUnitPrice] NUMERIC(20,5) NULL DEFAULT ,
    [MaterialOrderTotalPrice] NUMERIC(20,5) NULL DEFAULT ,
    [MaterialOrderItemDesc] NVARCHAR(MAX) NULL DEFAULT ,
    [IsCancel] BIT NULL DEFAULT ,
    [MaterialOrderRemainQty] NUMERIC(20,5) NULL DEFAULT ,
    [PlanGrDate] DATE NULL DEFAULT ,
    [MOIExtText01] NVARCHAR(MAX) NULL DEFAULT ,
    [MOIExtText02] NVARCHAR(MAX) NULL DEFAULT ,
    [MOIExtText03] NVARCHAR(MAX) NULL DEFAULT ,
    [MrpTargetNo] NVARCHAR(20) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

