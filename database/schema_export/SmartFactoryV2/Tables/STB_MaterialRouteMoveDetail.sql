CREATE TABLE [dbo].[STB_MaterialRouteMoveDetail] (
    [MaterialRouteMoveDetailNo] VARCHAR(20) NOT NULL DEFAULT ,
    [MaterialRouteMoveNo] VARCHAR(20) NOT NULL DEFAULT ,
    [MaterialCode] VARCHAR(50) NULL DEFAULT ,
    [MaterialStockAttribute] VARCHAR(20) NULL DEFAULT ,
    [MaterialAttribute] VARCHAR(20) NULL DEFAULT ,
    [StockAttrib1] VARCHAR(20) NULL DEFAULT ,
    [StockAttrib2] VARCHAR(20) NULL DEFAULT ,
    [StockAttrib3] VARCHAR(20) NULL DEFAULT ,
    [MRMDExtText01] NVARCHAR(MAX) NULL DEFAULT ,
    [MRMDExtText02] NVARCHAR(MAX) NULL DEFAULT ,
    [MRMDExtText03] NVARCHAR(MAX) NULL DEFAULT ,
    [RequestQty] NUMERIC(20,5) NULL DEFAULT ,
    [AllowQty] NUMERIC(20,5) NULL DEFAULT ,
    [PickingAssingQty] NUMERIC(20,5) NULL DEFAULT ,
    [PickingQty] NUMERIC(20,5) NULL DEFAULT ,
    [MoveQty] NUMERIC(20,5) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

