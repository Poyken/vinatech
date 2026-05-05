CREATE TABLE [dbo].[Stb_InventoryUpLine] (
    [Id] BIGINT IDENTITY(1,1) NOT NULL DEFAULT ,
    [InputLineCode] VARCHAR(50) NULL DEFAULT ,
    [ChildMaterialCode] VARCHAR(50) NULL DEFAULT ,
    [BomUnit] VARCHAR(50) NULL DEFAULT ,
    [InventoryNvl] NUMERIC(20,5) NULL DEFAULT ,
    [Months] INT NULL DEFAULT ,
    [Years] INT NULL DEFAULT ,
    [MaterialName] NVARCHAR(100) NULL DEFAULT ,
    [CreateDate] DATETIME NULL DEFAULT ,
    [WorkCenterCode] VARCHAR(30) NULL DEFAULT ,
    [Typeinput] NVARCHAR(200) NULL DEFAULT 
);
GO

