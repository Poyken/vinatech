CREATE TABLE [dbo].[STB_ProductsReceiptHist_backup] (
    [Barcode] VARCHAR(20) NOT NULL DEFAULT ,
    [InvoiceNo] VARCHAR(40) NULL DEFAULT ,
    [BLNo] VARCHAR(20) NULL DEFAULT ,
    [PackingDate] DATETIME NULL DEFAULT ,
    [ShipmentDate] DATETIME NULL DEFAULT ,
    [TransportationMethodCode] VARCHAR(2) NULL DEFAULT ,
    [MaterialCode] VARCHAR(20) NULL DEFAULT ,
    [ProdQty] NUMERIC(20,5) NULL DEFAULT ,
    [IsHeadOfficeConfirm] BIT NOT NULL DEFAULT ,
    [HeadOfficeConfirmDate] DATETIME NULL DEFAULT ,
    [Remark] NVARCHAR(MAX) NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    [IsHeadOfficeQcConfirm] BIT NOT NULL DEFAULT ,
    [HeadOfficeQcConfirmDate] DATETIME NULL DEFAULT ,
    [VNNameProduct] NVARCHAR(200) NULL DEFAULT ,
    [ID] INT IDENTITY(1,1) NOT NULL DEFAULT 
);
GO

