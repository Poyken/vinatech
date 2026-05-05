CREATE TABLE [dbo].[STB_PassLabelPrintHist] (
    [PassLabelPrintNo] VARCHAR(20) NOT NULL DEFAULT ,
    [MaterialCode] VARCHAR(20) NULL DEFAULT ,
    [TestDate] DATE NULL DEFAULT ,
    [ManDate] DATE NULL DEFAULT ,
    [TestUserID] VARCHAR(20) NULL DEFAULT ,
    [StockQty] NUMERIC(20,2) NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    [Barcode] VARCHAR(100) NULL DEFAULT ,
    [MaterialUnit] VARCHAR(10) NULL DEFAULT 
);
GO

