CREATE TABLE [dbo].[STB_MaterialType] (
    [MaterialTypeCode] VARCHAR(20) NOT NULL DEFAULT ,
    [BasicMaterialType] VARCHAR(20) NULL DEFAULT ,
    [MaterialTypeName] NVARCHAR(100) NULL DEFAULT ,
    [MaterialTypeNameL] NVARCHAR(100) NULL DEFAULT ,
    [IsUsed] BIT NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

