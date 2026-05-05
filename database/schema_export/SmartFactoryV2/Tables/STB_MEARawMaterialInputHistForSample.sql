CREATE TABLE [dbo].[STB_MEARawMaterialInputHistForSample] (
    [MEARawMaterialInputHistNo] VARCHAR(20) NOT NULL DEFAULT ,
    [InputDate] DATE NULL DEFAULT ,
    [MaterialCode] VARCHAR(20) NULL DEFAULT ,
    [RawMaterialBarcode] VARCHAR(50) NULL DEFAULT ,
    [InputQty] NUMERIC(20,5) NULL DEFAULT ,
    [Remark] NVARCHAR(MAX) NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

