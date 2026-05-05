CREATE TABLE [dbo].[STB_SpecGroup] (
    [SpecGroupCode] VARCHAR(20) NOT NULL DEFAULT ,
    [SpecGroupName] NVARCHAR(50) NULL DEFAULT ,
    [SpecGroupNameL] NVARCHAR(50) NULL DEFAULT ,
    [IsUsed] BIT NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

