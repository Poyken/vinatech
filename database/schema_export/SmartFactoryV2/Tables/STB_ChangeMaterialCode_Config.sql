CREATE TABLE [dbo].[STB_ChangeMaterialCode_Config] (
    [ID] INT IDENTITY(1,1) NOT NULL DEFAULT ,
    [oldMaterialCode] NVARCHAR(50) NULL DEFAULT ,
    [NewMaterialCode] NVARCHAR(100) NULL DEFAULT ,
    [ConvertedCode] NVARCHAR(50) NULL DEFAULT ,
    [Voltage] DECIMAL(18,2) NULL DEFAULT ,
    [Farad] DECIMAL(18,2) NULL DEFAULT ,
    [MBISizeW] DECIMAL(5,2) NULL DEFAULT ,
    [MBISizeH] DECIMAL(5,2) NULL DEFAULT ,
    [CreatedDate] DATETIME NULL DEFAULT (getdate()),
    [CreatedBy] NVARCHAR(50) NULL DEFAULT 
);
GO

