CREATE TABLE [dbo].[STB_ScreenLayoutInfoBack] (
    [Name] VARCHAR(50) NOT NULL DEFAULT ,
    [DeveloperVersion] VARCHAR(20) NOT NULL DEFAULT ,
    [Version] INT NOT NULL DEFAULT ,
    [Layout] VARBINARY(MAX) NOT NULL DEFAULT ,
    [XmlLayout] NVARCHAR(MAX) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT 
);
GO

