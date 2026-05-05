CREATE TABLE [dbo].[STB_DocContentsInfo] (
    [ContentsCode] VARCHAR(10) NOT NULL DEFAULT ,
    [ContentsName] NVARCHAR(100) NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

