CREATE TABLE [dbo].[STB_UserTypeViewPermission] (
    [UserType] VARCHAR(20) NOT NULL DEFAULT ,
    [Name] VARCHAR(50) NOT NULL DEFAULT ,
    [ViewName] VARCHAR(50) NOT NULL DEFAULT ,
    [AllowAdd] BIT NULL DEFAULT ,
    [AllowModify] BIT NULL DEFAULT ,
    [AllowDelete] BIT NULL DEFAULT ,
    [AllowExcel] BIT NULL DEFAULT ,
    [AllowImport] BIT NULL DEFAULT ,
    CONSTRAINT [PK_STB_UserTypeViewPermission] PRIMARY KEY CLUSTERED ([UserType], [Name], [ViewName])
);
GO

