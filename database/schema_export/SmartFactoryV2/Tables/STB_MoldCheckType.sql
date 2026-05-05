CREATE TABLE [dbo].[STB_MoldCheckType] (
    [MoldCheckTypeCode] VARCHAR(20) NOT NULL DEFAULT ,
    [MoldCheckTypeName] NVARCHAR(50) NULL DEFAULT ,
    [MoldCheckTypeDesc] NVARCHAR(200) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

