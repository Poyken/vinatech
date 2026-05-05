CREATE TABLE [dbo].[STB_StartupCheckItemMaster] (
    [MaterialTypeCode] VARCHAR(20) NOT NULL DEFAULT ,
    [RouteCode] VARCHAR(20) NOT NULL DEFAULT ,
    [CheckItemCode] VARCHAR(10) NOT NULL DEFAULT ,
    [CheckItemName] NVARCHAR(200) NULL DEFAULT ,
    [CheckItemShortName] NVARCHAR(100) NULL DEFAULT ,
    [CheckIndex] INT NULL DEFAULT ,
    [CheckType] VARCHAR(10) NULL DEFAULT ,
    [IsMandatory] VARCHAR(1) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChagneUserID] VARCHAR(20) NULL DEFAULT ,
    CONSTRAINT [PK_STB_StartupCheckItemMaster] PRIMARY KEY CLUSTERED ([MaterialTypeCode], [RouteCode], [CheckItemCode])
);
GO

