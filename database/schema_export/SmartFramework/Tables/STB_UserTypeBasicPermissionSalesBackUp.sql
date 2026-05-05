CREATE TABLE [dbo].[STB_UserTypeBasicPermissionSalesBackUp] (
    [UserType] VARCHAR(20) NOT NULL DEFAULT ,
    [Name] VARCHAR(50) NOT NULL DEFAULT ,
    [AllowView] BIT NULL DEFAULT ,
    [AllowAdd] BIT NULL DEFAULT ,
    [AllowModify] BIT NULL DEFAULT ,
    [AllowDelete] BIT NULL DEFAULT 
);
GO

