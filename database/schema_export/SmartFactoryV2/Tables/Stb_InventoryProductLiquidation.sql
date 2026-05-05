CREATE TABLE [dbo].[Stb_InventoryProductLiquidation] (
    [ID] INT IDENTITY(1,1) NOT NULL DEFAULT ,
    [MaterialCode] NVARCHAR(50) NULL DEFAULT ,
    [OpenningInventory] NUMERIC(20,5) NULL DEFAULT ,
    [SumIn] NVARCHAR(20) NULL DEFAULT ,
    [SumOut] NVARCHAR(20) NULL DEFAULT ,
    [Period] DATE NULL DEFAULT ,
    [MaterialName] NVARCHAR(200) NULL DEFAULT ,
    [WorkCenterCode] VARCHAR(20) NULL DEFAULT ,
    [Model] VARCHAR(255) NULL DEFAULT 
);
GO

