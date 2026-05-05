CREATE TABLE [dbo].[STB_SpreadTempleteInfo] (
    [TempleteName] NVARCHAR(100) NOT NULL DEFAULT ,
    [TempleteDescription] NVARCHAR(MAX) NULL DEFAULT ,
    [FileID] BIGINT NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

