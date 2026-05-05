CREATE TABLE [dbo].[STB_StringResources] (
    [Language] VARCHAR(20) NOT NULL DEFAULT ,
    [Type] VARCHAR(20) NOT NULL DEFAULT ,
    [Name] NVARCHAR(200) NOT NULL DEFAULT ,
    [Value] NVARCHAR(500) NOT NULL DEFAULT ,
    [Description] NVARCHAR(200) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    CONSTRAINT [PK_STB_StringResources] PRIMARY KEY CLUSTERED ([Language], [Type], [Name])
);
GO

