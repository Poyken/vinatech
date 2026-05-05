CREATE TABLE [dbo].[STB_MEARawMaterialInputHist] (
    [MEARawMaterialInputHistNo] VARCHAR(20) NOT NULL DEFAULT ,
    [Barcode] VARCHAR(20) NOT NULL DEFAULT ,
    [ProductGroupCode] VARCHAR(20) NOT NULL DEFAULT ,
    [RawMaterialBarcode] VARCHAR(200) NULL DEFAULT ,
    [Qty] NUMERIC(20,5) NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    [Remark] NVARCHAR(MAX) NULL DEFAULT ,
    [MEADefectDivCode] VARCHAR(20) NULL DEFAULT ,
    [WorkerCode] VARCHAR(20) NULL DEFAULT 
);
GO

