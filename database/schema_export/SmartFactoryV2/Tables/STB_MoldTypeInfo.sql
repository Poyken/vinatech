CREATE TABLE [dbo].[STB_MoldTypeInfo] (
    [MoldTypeCode] VARCHAR(20) NOT NULL DEFAULT ,
    [MoldTypeName] NVARCHAR(50) NULL DEFAULT ,
    [MoldTypeDesc] NVARCHAR(200) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

