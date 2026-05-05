CREATE TABLE [dbo].[STB_DayProdPlanOrderBatchInfo] (
    [DayProdPlanOrderBatchNo] VARCHAR(20) NOT NULL DEFAULT ,
    [PlanYearMonth] CHAR(7) NOT NULL DEFAULT ,
    [ParentPONo] VARCHAR(20) NOT NULL DEFAULT ,
    [TargetPONo] VARCHAR(20) NOT NULL DEFAULT ,
    [LineCode] VARCHAR(20) NULL DEFAULT ,
    [PlanShiftCode] VARCHAR(20) NULL DEFAULT ,
    [PlanDate] DATE NULL DEFAULT ,
    [PlanQty] NUMERIC(20,5) NULL DEFAULT ,
    [DayPlanNo] VARCHAR(20) NULL DEFAULT ,
    [Barcode] VARCHAR(20) NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

