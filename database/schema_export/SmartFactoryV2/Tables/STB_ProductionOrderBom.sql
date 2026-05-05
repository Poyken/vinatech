CREATE TABLE [dbo].[STB_ProductionOrderBom] (
    [Id] VARCHAR(50) NULL DEFAULT ,
    [ParentId] VARCHAR(50) NULL DEFAULT ,
    [PONo] VARCHAR(20) NOT NULL DEFAULT ,
    [MaterialCode] VARCHAR(50) NOT NULL DEFAULT ,
    [BomVersion] VARCHAR(20) NOT NULL DEFAULT ,
    [ChildMaterialCode] VARCHAR(50) NOT NULL DEFAULT ,
    [ChildBomVersion] VARCHAR(20) NOT NULL DEFAULT ,
    [BomUnit] VARCHAR(10) NULL DEFAULT ,
    [UsedQty] NUMERIC(20,5) NULL DEFAULT ,
    [TotalUsedQty] NUMERIC(20,5) NULL DEFAULT ,
    [MaterialUnitUsedQty] NUMERIC(38,19) NULL DEFAULT ,
    [MaterialUnitTotalUsedQty] NUMERIC(38,19) NULL DEFAULT ,
    [RouteCode] VARCHAR(20) NULL DEFAULT ,
    [IsOptionItem] BIT NULL DEFAULT ,
    [IsUseProduction] BIT NULL DEFAULT ,
    [BomDetailDesc] VARCHAR(200) NULL DEFAULT ,
    [StdCombSec] INT NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

