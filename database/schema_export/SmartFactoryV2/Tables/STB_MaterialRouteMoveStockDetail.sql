CREATE TABLE [dbo].[STB_MaterialRouteMoveStockDetail] (
    [MaterialRouteMoveDetailNo] VARCHAR(20) NOT NULL DEFAULT ,
    [MaterialStockNo] BIGINT NOT NULL DEFAULT ,
    [PickingAssingQty] NUMERIC(20,5) NULL DEFAULT ,
    [PickingQty] NUMERIC(20,5) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    CONSTRAINT [PK_STB_MaterialRouteMoveStockDetail] PRIMARY KEY CLUSTERED ([MaterialRouteMoveDetailNo], [MaterialStockNo])
);
GO

