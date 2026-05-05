CREATE TABLE [dbo].[STB_ProductsReceiptHist] (
    [Barcode] VARCHAR(20) NOT NULL DEFAULT ,
    [InvoiceNo] VARCHAR(40) NULL DEFAULT ,
    [BLNo] VARCHAR(20) NULL DEFAULT ,
    [PackingDate] DATETIME NULL DEFAULT ,
    [ShipmentDate] DATETIME NULL DEFAULT ,
    [TransportationMethodCode] NVARCHAR(20) NULL DEFAULT ,
    [MaterialCode] VARCHAR(20) NULL DEFAULT ,
    [ProdQty] NUMERIC(20,5) NULL DEFAULT ,
    [IsHeadOfficeConfirm] BIT NOT NULL DEFAULT (CONVERT([bit],(0),0)),
    [HeadOfficeConfirmDate] DATETIME NULL DEFAULT ,
    [Remark] NVARCHAR(MAX) NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    [IsHeadOfficeQcConfirm] BIT NOT NULL DEFAULT (CONVERT([bit],(0),0)),
    [HeadOfficeQcConfirmDate] DATETIME NULL DEFAULT ,
    [VNNameProduct] NVARCHAR(200) NULL DEFAULT ,
    [ID] INT IDENTITY(1,1) NOT NULL DEFAULT ,
    [Nation] VARCHAR(100) NULL DEFAULT ,
    [Customer] VARCHAR(100) NULL DEFAULT ,
    [Size] VARCHAR(50) NULL DEFAULT ,
    [HeadOfficeQcStatusCode] VARCHAR(10) NULL DEFAULT ,
    [CODEID] NVARCHAR(100) NULL DEFAULT ,
    [WorkCenterCode] NVARCHAR(20) NULL DEFAULT 
);
GO

