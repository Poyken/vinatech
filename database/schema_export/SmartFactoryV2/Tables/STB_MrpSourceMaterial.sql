CREATE TABLE [dbo].[STB_MrpSourceMaterial] (
    [MrpSourceNo] VARCHAR(20) NOT NULL DEFAULT ,
    [MrpNo] VARCHAR(20) NOT NULL DEFAULT ,
    [MaterialCode] VARCHAR(50) NULL DEFAULT ,
    [BomVersion] VARCHAR(20) NULL DEFAULT ,
    [ProdPlanDate] DATE NULL DEFAULT ,
    [PlanQty] NUMERIC(20,5) NULL DEFAULT ,
    [AdjustQty] NUMERIC(20,5) NULL DEFAULT ,
    [FixedQty] NUMERIC(20,5) NULL DEFAULT ,
    [IsNotInclude] BIT NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

