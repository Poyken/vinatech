CREATE TABLE [dbo].[STB_RawMaterialInputHist_20200102] (
    [RawMaterialInputHistNo] VARCHAR(20) NOT NULL DEFAULT ,
    [Barcode] VARCHAR(20) NOT NULL DEFAULT ,
    [ProductGroupCode] VARCHAR(20) NOT NULL DEFAULT ,
    [RawMaterialBarcode] VARCHAR(200) NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

