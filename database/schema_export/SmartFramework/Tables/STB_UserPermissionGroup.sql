CREATE TABLE [dbo].[STB_UserPermissionGroup] (
    [UserID] VARCHAR(20) NOT NULL DEFAULT ,
    [UserType] VARCHAR(20) NOT NULL DEFAULT ,
    [HasPermission] BIT NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    CONSTRAINT [PK_STB_UserPermissionGroup] PRIMARY KEY CLUSTERED ([UserID], [UserType])
);
GO

