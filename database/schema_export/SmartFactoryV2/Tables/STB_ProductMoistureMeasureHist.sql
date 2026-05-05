CREATE TABLE [dbo].[STB_ProductMoistureMeasureHist] (
    [MoistureMeasureHistNo] VARCHAR(20) NOT NULL DEFAULT ,
    [MaterialCode] VARCHAR(20) NULL DEFAULT ,
    [Barcode] VARCHAR(20) NULL DEFAULT ,
    [IsAging] BIT NULL DEFAULT ,
    [AgingCount] INT NULL DEFAULT ,
    [ProductMoistureValue] NUMERIC(10,2) NULL DEFAULT ,
    [ActionContents] NVARCHAR(MAX) NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    [Remark] NVARCHAR(MAX) NULL DEFAULT 
);
GO

