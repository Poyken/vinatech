CREATE TABLE [dbo].[STB_VietnamLabelPrintHist] (
    [VietnamLabelPrintHistNo] BIGINT IDENTITY(1,1) NOT NULL DEFAULT ,
    [OriginalBarcode] VARCHAR(20) NULL DEFAULT ,
    [MaterialCode] VARCHAR(20) NULL DEFAULT ,
    [MaterialName] NVARCHAR(100) NULL DEFAULT ,
    [ChangeBarcode] VARCHAR(20) NULL DEFAULT ,
    [Voltage] VARCHAR(10) NULL DEFAULT ,
    [Farad] VARCHAR(10) NULL DEFAULT ,
    [Rating] VARCHAR(10) NULL DEFAULT ,
    [PartNo] NVARCHAR(100) NULL DEFAULT ,
    [PackingID] VARCHAR(20) NULL DEFAULT ,
    [LotQty] INT NULL DEFAULT ,
    [LabelQty] INT NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

