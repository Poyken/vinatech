CREATE TABLE [dbo].[STB_UserTypeFunctionPermission] (
    [UserType] VARCHAR(20) NOT NULL DEFAULT ,
    [Name] VARCHAR(50) NOT NULL DEFAULT ,
    [FunctionName] VARCHAR(50) NOT NULL DEFAULT ,
    [Allow] BIT NULL DEFAULT ,
    CONSTRAINT [PK_STB_UserTypeFunctionPermission] PRIMARY KEY CLUSTERED ([UserType], [Name], [FunctionName])
);
GO

