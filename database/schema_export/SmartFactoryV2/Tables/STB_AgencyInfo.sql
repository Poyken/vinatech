CREATE TABLE [dbo].[STB_AgencyInfo] (
    [AgencyCode] VARCHAR(20) NOT NULL DEFAULT ,
    [AgencyName] NVARCHAR(100) NULL DEFAULT ,
    [IsUsed] BIT NOT NULL DEFAULT (CONVERT([bit],(1),0)),
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    [CountryName] NVARCHAR(100) NULL DEFAULT ,
    [AgencyAbbreviationName] NVARCHAR(100) NULL DEFAULT ,
    [Remark] NVARCHAR(MAX) NULL DEFAULT 
);
GO

