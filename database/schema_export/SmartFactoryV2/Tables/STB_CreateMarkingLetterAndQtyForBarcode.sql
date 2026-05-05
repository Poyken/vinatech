CREATE TABLE [dbo].[STB_CreateMarkingLetterAndQtyForBarcode] (
    [MarkingCode] VARCHAR(50) NOT NULL DEFAULT ,
    [MarkingName] VARCHAR(50) NULL DEFAULT ,
    [Barcode] VARCHAR(50) NULL DEFAULT ,
    [Qty] INT NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(50) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(50) NULL DEFAULT ,
    [WorkCenterCode] VARCHAR(20) NULL DEFAULT ,
    [Packing] NVARCHAR(50) NULL DEFAULT 
);
GO

