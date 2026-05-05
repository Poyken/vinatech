CREATE TABLE [dbo].[STB_MaterialMoveHistory] (
    [MoveHistoryNo] BIGINT IDENTITY(1,1) NOT NULL DEFAULT ,
    [MoveDate] DATE NULL DEFAULT ,
    [MoveDateTime] DATETIME NULL DEFAULT ,
    [MaterialLotNo] VARCHAR(20) NULL DEFAULT ,
    [LotID] VARCHAR(50) NULL DEFAULT ,
    [MaterialCode] VARCHAR(50) NULL DEFAULT ,
    [SourceMaterialWarehouseCode] VARCHAR(20) NULL DEFAULT ,
    [SourceMaterialLocationCode] VARCHAR(20) NULL DEFAULT ,
    [SourceZone] NVARCHAR(100) NULL DEFAULT ,
    [TargetMaterialWarehouseCode] VARCHAR(20) NULL DEFAULT ,
    [TargetMaterialLocationCode] VARCHAR(20) NULL DEFAULT ,
    [TargetZone] NVARCHAR(100) NULL DEFAULT ,
    [MoveStockQty] NUMERIC(20,5) NULL DEFAULT ,
    [MoveUserID] VARCHAR(20) NULL DEFAULT 
);
GO

