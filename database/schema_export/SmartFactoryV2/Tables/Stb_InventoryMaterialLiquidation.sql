CREATE TABLE [dbo].[Stb_InventoryMaterialLiquidation] (
    [ID] INT IDENTITY(1,1) NOT NULL DEFAULT ,
    [MaterialCode] NVARCHAR(20) NULL DEFAULT ,
    [FirstInventory] NUMERIC(20,5) NULL DEFAULT ,
    [SumIn] NVARCHAR(50) NULL DEFAULT ,
    [SumOut] NVARCHAR(50) NULL DEFAULT ,
    [Period] DATE NULL DEFAULT ,
    [WorkCenterCode] VARCHAR(50) NULL DEFAULT 
);
GO

