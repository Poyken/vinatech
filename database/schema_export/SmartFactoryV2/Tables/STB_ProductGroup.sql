CREATE TABLE [dbo].[STB_ProductGroup] (
    [ProductGroupCode] VARCHAR(20) NOT NULL DEFAULT ,
    [ProductGroupName] NVARCHAR(50) NULL DEFAULT ,
    [ProductGroupNameL] NVARCHAR(50) NULL DEFAULT ,
    [ProductGroupDesc] NVARCHAR(MAX) NULL DEFAULT ,
    [ProductGroupDescL] NVARCHAR(MAX) NULL DEFAULT ,
    [IsUsed] BIT NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

