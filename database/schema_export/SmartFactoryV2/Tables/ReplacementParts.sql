CREATE TABLE [dbo].[ReplacementParts] (
    [Id] INT IDENTITY(1,1) NOT NULL DEFAULT ,
    [SparePartId] INT NOT NULL DEFAULT ,
    [SparePartCode] NVARCHAR(MAX) NOT NULL DEFAULT ,
    [SelectedQty] DECIMAL(18,2) NOT NULL DEFAULT ,
    [StockName] NVARCHAR(MAX) NULL DEFAULT ,
    [WorkCenterCode] NVARCHAR(MAX) NULL DEFAULT ,
    [IsDeleted] BIT NOT NULL DEFAULT 
);
GO

