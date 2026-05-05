CREATE TABLE [dbo].[STB_VVT_UserWarning] (
    [id] INT IDENTITY(1,1) NOT NULL DEFAULT ,
    [username] VARCHAR(50) NOT NULL DEFAULT ,
    [password] VARCHAR(50) NOT NULL DEFAULT ,
    [groupid] VARCHAR(50) NULL DEFAULT ,
    [typeid] VARCHAR(50) NULL DEFAULT ,
    [password2] VARCHAR(50) NULL DEFAULT ,
    [createdatetime] DATETIME NULL DEFAULT (getdate()),
    [createuserid] VARCHAR(50) NULL DEFAULT ,
    [changedatetime] DATETIME NULL DEFAULT ,
    [changeuserid] VARCHAR(50) NULL DEFAULT 
);
GO

