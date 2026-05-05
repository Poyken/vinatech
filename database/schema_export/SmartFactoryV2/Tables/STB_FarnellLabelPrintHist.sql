CREATE TABLE [dbo].[STB_FarnellLabelPrintHist] (
    [ID] INT IDENTITY(1,1) NOT NULL DEFAULT ,
    [LabelType] NVARCHAR(50) NULL DEFAULT ,
    [CustomerPO] VARCHAR(50) NULL DEFAULT ,
    [PackingListNumber] VARCHAR(50) NULL DEFAULT ,
    [CustomerPartNumber] VARCHAR(50) NULL DEFAULT ,
    [SupplierPartNumber] VARCHAR(50) NULL DEFAULT ,
    [Quantity] VARCHAR(10) NULL DEFAULT ,
    [DateCodes] VARCHAR(10) NULL DEFAULT ,
    [LotCodes] VARCHAR(50) NULL DEFAULT ,
    [SerialNumber] VARCHAR(50) NULL DEFAULT ,
    [ProdLabelQty] VARCHAR(10) NULL DEFAULT ,
    [LogLabelQty] VARCHAR(10) NULL DEFAULT ,
    [PrintTime] DATETIME NULL DEFAULT ,
    [PrintUserID] VARCHAR(20) NULL DEFAULT 
);
GO

