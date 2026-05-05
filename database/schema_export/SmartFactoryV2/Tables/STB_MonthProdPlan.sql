CREATE TABLE [dbo].[STB_MonthProdPlan] (
    [CompanyCode] VARCHAR(20) NOT NULL DEFAULT ,
    [WorkCenterCode] VARCHAR(20) NOT NULL DEFAULT ,
    [PlanYearMonth] DATE NOT NULL DEFAULT ,
    [MaterialCode] VARCHAR(20) NOT NULL DEFAULT ,
    [PlanQty] INT NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    [LineCode] VARCHAR(20) NOT NULL DEFAULT ,
    [Batch] INT NULL DEFAULT ,
    [MaterialName] VARCHAR(60) NULL DEFAULT ,
    CONSTRAINT [PK_STB_MonthProdPlan] PRIMARY KEY CLUSTERED ([CompanyCode], [WorkCenterCode], [PlanYearMonth], [LineCode], [MaterialCode])
);
GO

