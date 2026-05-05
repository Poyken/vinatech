CREATE TABLE [dbo].[STB_SpecItem] (
    [SpecItemCode] VARCHAR(20) NOT NULL DEFAULT ,
    [ProductGroupCode] VARCHAR(20) NOT NULL DEFAULT ,
    [SpecGroupCode] VARCHAR(20) NULL DEFAULT ,
    [SpecItemName] NVARCHAR(100) NULL DEFAULT ,
    [SpecItemNameL] NVARCHAR(100) NULL DEFAULT ,
    [SpecItemCheckType] VARCHAR(1) NULL DEFAULT ,
    [IsUsed] BIT NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    [Remark] NVARCHAR(500) NULL DEFAULT 
);
GO

