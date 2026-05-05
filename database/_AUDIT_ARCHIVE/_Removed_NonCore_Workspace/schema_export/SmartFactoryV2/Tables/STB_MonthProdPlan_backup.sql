CREATE TABLE [dbo].[STB_MonthProdPlan_backup] (
    [CompanyCode] VARCHAR(20) NOT NULL DEFAULT ,
    [WorkCenterCode] VARCHAR(20) NOT NULL DEFAULT ,
    [PlanYearMonth] DATE NOT NULL DEFAULT ,
    [MaterialCode] VARCHAR(20) NOT NULL DEFAULT ,
    [PlanQty] INT NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    [LineCode] VARCHAR(20) NOT NULL DEFAULT ,
    [Batch] INT NULL DEFAULT ,
    [MaterialName] VARCHAR(60) NULL DEFAULT 
);
GO

