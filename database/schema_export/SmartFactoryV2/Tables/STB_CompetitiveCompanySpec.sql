CREATE TABLE [dbo].[STB_CompetitiveCompanySpec] (
    [CompetitiveCompanySpecNo] VARCHAR(20) NOT NULL DEFAULT ,
    [BaseDate] DATE NOT NULL DEFAULT ,
    [CompetitiveCompanyCode] VARCHAR(20) NULL DEFAULT ,
    [ProductSize] VARCHAR(10) NULL DEFAULT ,
    [ProductSpec] VARCHAR(20) NULL DEFAULT ,
    [ProductType] VARCHAR(20) NULL DEFAULT ,
    [Remark] NVARCHAR(MAX) NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

