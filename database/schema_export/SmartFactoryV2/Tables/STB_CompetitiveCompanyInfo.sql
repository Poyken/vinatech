CREATE TABLE [dbo].[STB_CompetitiveCompanyInfo] (
    [CompetitiveCompanyCode] VARCHAR(20) NOT NULL DEFAULT ,
    [CompetitiveCompanyName] NVARCHAR(100) NULL DEFAULT ,
    [IsUsed] BIT NOT NULL DEFAULT (CONVERT([bit],(1),0)),
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

