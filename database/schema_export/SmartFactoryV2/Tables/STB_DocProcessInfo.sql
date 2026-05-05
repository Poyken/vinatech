CREATE TABLE [dbo].[STB_DocProcessInfo] (
    [ProcessCode] VARCHAR(10) NOT NULL DEFAULT ,
    [ProcessName] NVARCHAR(100) NULL DEFAULT ,
    [Remark] VARCHAR(100) NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

