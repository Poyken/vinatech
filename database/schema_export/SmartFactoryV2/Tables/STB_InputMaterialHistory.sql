CREATE TABLE [dbo].[STB_InputMaterialHistory] (
    [ID] INT IDENTITY(1,1) NOT NULL DEFAULT ,
    [Barcode] NVARCHAR(50) NULL DEFAULT ,
    [RawMaterialBarcode] NVARCHAR(100) NULL DEFAULT ,
    [CreateUserID] NVARCHAR(50) NULL DEFAULT ,
    [ProductGroupCode] NVARCHAR(50) NULL DEFAULT ,
    [CreatedDate] DATETIME NULL DEFAULT (getdate())
);
GO

