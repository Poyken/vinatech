CREATE TABLE [dbo].[STB_SlittingLocationConfig_VVT] (
    [id] INT IDENTITY(1,1) NOT NULL DEFAULT ,
    [PartNo] VARCHAR(100) NULL DEFAULT ,
    [CoatingCode] VARCHAR(100) NULL DEFAULT ,
    [SlittingCode] VARCHAR(100) NULL DEFAULT ,
    [SlittingSize] VARCHAR(100) NULL DEFAULT ,
    [Farad] FLOAT NULL DEFAULT ,
    [Width] FLOAT NULL DEFAULT ,
    [RollQty] INT NULL DEFAULT ,
    [PositiveLocation] VARCHAR(100) NULL DEFAULT ,
    [NegativeLocation] VARCHAR(100) NULL DEFAULT ,
    [LengthActive] FLOAT NULL DEFAULT ,
    [LengthPassive] FLOAT NULL DEFAULT ,
    [CoatingType] VARCHAR(100) NULL DEFAULT ,
    [BinderUse] VARCHAR(100) NULL DEFAULT ,
    [WarehouseLocation] VARCHAR(50) NULL DEFAULT ,
    [LocationWarehouse] VARCHAR(50) NULL DEFAULT 
);
GO

