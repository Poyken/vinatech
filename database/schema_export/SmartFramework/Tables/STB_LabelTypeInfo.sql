CREATE TABLE [dbo].[STB_LabelTypeInfo] (
    [LabelType] NVARCHAR(30) NOT NULL DEFAULT ,
    [LabelTypeName] NVARCHAR(100) NULL DEFAULT ,
    [LabelTypeDesc] NVARCHAR(MAX) NULL DEFAULT ,
    [IsUsed] BIT NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

