CREATE TABLE [dbo].[STB_VendorBarcodeInfo] (
    [VendorCode] VARCHAR(20) NOT NULL DEFAULT ,
    [ProductGroupCode] VARCHAR(20) NOT NULL DEFAULT ,
    [DataType] VARCHAR(20) NOT NULL DEFAULT ,
    [StartIndex] INT NULL DEFAULT ,
    [DataLength] INT NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    CONSTRAINT [PK_STB_VendorBarcodeInfo] PRIMARY KEY CLUSTERED ([VendorCode], [ProductGroupCode], [DataType])
);
GO

