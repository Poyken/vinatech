CREATE TABLE [dbo].[Stb_VVT_ElectrodeChildConfig_VVT] (
    [ElectrodeCode] VARCHAR(30) NULL DEFAULT ,
    [MaterialCode] VARCHAR(30) NULL DEFAULT ,
    [MaterialName] VARCHAR(200) NULL DEFAULT ,
    [Prefix] VARCHAR(30) NULL DEFAULT ,
    [Suffix] VARCHAR(30) NULL DEFAULT ,
    [Contain] VARCHAR(30) NULL DEFAULT ,
    [Proper1] VARCHAR(30) NULL DEFAULT ,
    [Proper2] VARCHAR(30) NULL DEFAULT ,
    [Length] INT NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT (getdate()),
    [CreateUserId] VARCHAR(30) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserId] VARCHAR(30) NULL DEFAULT 
);
GO

