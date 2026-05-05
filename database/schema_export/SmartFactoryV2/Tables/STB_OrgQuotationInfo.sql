CREATE TABLE [dbo].[STB_OrgQuotationInfo] (
    [OrgQuotationNo] VARCHAR(20) NOT NULL DEFAULT ,
    [CompanyCode] VARCHAR(20) NULL DEFAULT ,
    [CustomerCode] VARCHAR(20) NULL DEFAULT ,
    [QuotationCreateDate] DATE NULL DEFAULT ,
    [QuotationUserID] VARCHAR(20) NULL DEFAULT ,
    [QuotationToName] NVARCHAR(50) NULL DEFAULT ,
    [QuotationToTelNo] NVARCHAR(50) NULL DEFAULT ,
    [QuotationToEmail] NVARCHAR(50) NULL DEFAULT ,
    [OrgQuotationText] NVARCHAR(100) NULL DEFAULT ,
    [OrgQuotationDesc] NVARCHAR(MAX) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

