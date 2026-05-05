CREATE TABLE [dbo].[STB_LineRouteMapping] (
    [LineCode] VARCHAR(20) NOT NULL DEFAULT ,
    [RouteCode] VARCHAR(20) NOT NULL DEFAULT ,
    [RouteIndex] INT NULL DEFAULT ,
    [IsProcessLineProduct] BIT NULL DEFAULT ,
    [MaterialWarehouseCode] VARCHAR(20) NULL DEFAULT ,
    [GILocationCode] VARCHAR(20) NULL DEFAULT ,
    [ErpRouteCode] VARCHAR(20) NULL DEFAULT ,
    [DayPlanNo] VARCHAR(20) NULL DEFAULT ,
    [ProdRouteHistNo] VARCHAR(20) NULL DEFAULT ,
    [IsLoss] BIT NULL DEFAULT ,
    [LossCode] VARCHAR(20) NULL DEFAULT ,
    [LossStartDateTime] DATETIME NULL DEFAULT ,
    [LossHistNo] VARCHAR(20) NULL DEFAULT ,
    [RouteWorkingStatus] VARCHAR(20) NULL DEFAULT ,
    [IsCall] BIT NULL DEFAULT ,
    [CallStartDateTime] DATETIME NULL DEFAULT ,
    [RunStartDateTime] DATETIME NULL DEFAULT ,
    [GRWarehouseCode] VARCHAR(20) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    [GRLocationCode] VARCHAR(20) NULL DEFAULT ,
    CONSTRAINT [PK_STB_LineRouteMapping] PRIMARY KEY CLUSTERED ([LineCode], [RouteCode])
);
GO

