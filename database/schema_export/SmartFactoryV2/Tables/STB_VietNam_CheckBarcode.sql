CREATE TABLE [dbo].[STB_VietNam_CheckBarcode] (
    [ID] INT IDENTITY(1,1) NOT NULL DEFAULT ,
    [Barcode1] VARCHAR(50) NULL DEFAULT ,
    [Barcode2] VARCHAR(50) NULL DEFAULT ,
    [Barcode3] VARCHAR(50) NULL DEFAULT ,
    [Remark] NVARCHAR(1000) NULL DEFAULT ,
    [CreateUserID] VARCHAR(30) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT (getdate())
);
GO

