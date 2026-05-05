CREATE TABLE [dbo].[STB_CompetitiveCompanyTrends] (
    [CompetitiveCompanyTrendsNo] VARCHAR(20) NOT NULL DEFAULT ,
    [BaseDate] DATE NOT NULL DEFAULT ,
    [CompetitiveCompanyCode] VARCHAR(20) NOT NULL DEFAULT ,
    [ContactWorkerName] NVARCHAR(100) NULL DEFAULT ,
    [InternetIssue] NVARCHAR(MAX) NULL DEFAULT ,
    [HomepageIssue] NVARCHAR(MAX) NULL DEFAULT ,
    [MainCustomers] NVARCHAR(MAX) NULL DEFAULT ,
    [Remark] NVARCHAR(MAX) NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

