CREATE TABLE [dbo].[STB_DocFileCheckResult] (
    [FileName] NVARCHAR(200) NOT NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NOT NULL DEFAULT ('eai')
);
GO

