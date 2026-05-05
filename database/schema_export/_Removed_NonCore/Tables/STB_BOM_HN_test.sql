CREATE TABLE [dbo].[STB_BOM_HN_test] (
    [MaterialCode] VARCHAR(50) NULL DEFAULT ,
    [BomVersion] VARCHAR(20) NULL DEFAULT ,
    [ChildMaterialCode] VARCHAR(50) NULL DEFAULT ,
    [ChildBomVersion] VARCHAR(20) NULL DEFAULT ,
    [BomUnit] VARCHAR(10) NULL DEFAULT ,
    [UsedQty] NUMERIC(20,10) NULL DEFAULT ,
    [RouteCode] VARCHAR(20) NULL DEFAULT ,
    [IsOptionItem] BIT NULL DEFAULT ,
    [BomDetailDesc] VARCHAR(200) NULL DEFAULT ,
    [StdCombSec] INT NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

