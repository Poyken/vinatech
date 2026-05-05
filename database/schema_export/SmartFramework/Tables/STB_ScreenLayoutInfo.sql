CREATE TABLE [dbo].[STB_ScreenLayoutInfo] (
    [Name] VARCHAR(50) NOT NULL DEFAULT ,
    [Version] INT NOT NULL DEFAULT ,
    [DeveloperVersion] VARCHAR(20) NOT NULL DEFAULT ,
    [Layout] VARBINARY(MAX) NULL DEFAULT ,
    [XmlLayout] NVARCHAR(MAX) NULL DEFAULT ,
    [Description] NVARCHAR(MAX) NULL DEFAULT ,
    [Snapshot] VARBINARY(MAX) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    CONSTRAINT [PK_STB_ScreenLayoutInfo] PRIMARY KEY CLUSTERED ([Name], [Version])
);
GO

