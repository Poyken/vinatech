CREATE TABLE [dbo].[STB_CompetitiveCompanyDetail] (
    [BaseDate] DATE NOT NULL DEFAULT ,
    [CompetitiveCompanyCode] VARCHAR(20) NOT NULL DEFAULT ,
    [SeparatorUsedQty] NUMERIC(20,4) NULL DEFAULT ,
    [StockPrice] NUMERIC(20,4) NULL DEFAULT ,
    [Remark] NVARCHAR(MAX) NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    CONSTRAINT [PK_STB_CompetitiveCompanyDetail] PRIMARY KEY CLUSTERED ([BaseDate], [CompetitiveCompanyCode])
);
GO

