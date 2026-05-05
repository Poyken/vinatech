CREATE TABLE [dbo].[sysdiagrams] (
    [name] NVARCHAR(128) NOT NULL DEFAULT ,
    [principal_id] INT NOT NULL DEFAULT ,
    [diagram_id] INT IDENTITY(1,1) NOT NULL DEFAULT ,
    [version] INT NULL DEFAULT ,
    [definition] VARBINARY(MAX) NULL DEFAULT 
);
GO

