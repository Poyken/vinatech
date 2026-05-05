CREATE TABLE [dbo].[STB_QuotationDetailInfo] (
    [QuotationDetailNo] VARCHAR(20) NOT NULL DEFAULT ,
    [QuotationNo] VARCHAR(20) NULL DEFAULT ,
    [QuotationDetailSeq] INT NULL DEFAULT ,
    [MaterialCode] VARCHAR(50) NULL DEFAULT ,
    [QuotationMaterialCode] NVARCHAR(50) NULL DEFAULT ,
    [QuotationMaterialName] NVARCHAR(100) NULL DEFAULT ,
    [QuotationMaterialSpec] NVARCHAR(MAX) NULL DEFAULT ,
    [QuotationQty] NUMERIC(20,5) NULL DEFAULT ,
    [QuotationUnitPrice] NUMERIC(20,5) NULL DEFAULT ,
    [QuotationItemDesc] NVARCHAR(MAX) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

