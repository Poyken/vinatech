CREATE TABLE [dbo].[STB_MaterialDocType] (
    [MaterialDocTypeCode] VARCHAR(20) NOT NULL DEFAULT ,
    [MaterialDocType] VARCHAR(10) NULL DEFAULT ,
    [MaterialDocTypeName] NVARCHAR(50) NULL DEFAULT ,
    [MaterialDocTypeNameL] NVARCHAR(50) NULL DEFAULT ,
    [MaterialDocTypeDesc] NVARCHAR(200) NULL DEFAULT ,
    [MaterialDocTypeDescL] NVARCHAR(200) NULL DEFAULT ,
    [MaterialDocTypeGroup] NVARCHAR(50) NULL DEFAULT ,
    [IsProcessBom] BIT NULL DEFAULT ,
    [IsProcessModelBom] BIT NULL DEFAULT ,
    [IsAutoCreate] BIT NULL DEFAULT ,
    [AutoCreateMoveType] VARCHAR(20) NULL DEFAULT ,
    [IsDecSource] BIT NULL DEFAULT ,
    [IsIncTarget] BIT NULL DEFAULT ,
    [IsChangeStockAttribute] BIT NULL DEFAULT ,
    [IsRequireQC] BIT NULL DEFAULT ,
    [IsRequireApproval] BIT NULL DEFAULT ,
    [IsProcessRefDoc] BIT NULL DEFAULT ,
    [IsDisplay] BIT NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

