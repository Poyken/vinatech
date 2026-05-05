CREATE TABLE [dbo].[STB_MrpTargetMaterial] (
    [MrpTargetNo] VARCHAR(20) NOT NULL DEFAULT ,
    [MrpNo] VARCHAR(20) NOT NULL DEFAULT ,
    [MaterialCode] VARCHAR(50) NULL DEFAULT ,
    [CalcQty] NUMERIC(20,5) NULL DEFAULT ,
    [AdjustQty] NUMERIC(20,5) NULL DEFAULT ,
    [FixedQty] NUMERIC(20,5) NULL DEFAULT ,
    [ProdPlanDate] DATE NULL DEFAULT ,
    [AgvGrDay] INT NULL DEFAULT ,
    [PlanOrderDate] DATE NULL DEFAULT ,
    [PlanGrDate] DATE NULL DEFAULT ,
    [CustomerCode] VARCHAR(20) NULL DEFAULT ,
    [MaterialOrderNo] VARCHAR(20) NULL DEFAULT ,
    [MaterialOrderItemNo] VARCHAR(20) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

