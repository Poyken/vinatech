CREATE TABLE [dbo].[ESM_DirectDayProdPlanHead] (
    [DirectDayProdPlanHeadNo] VARCHAR(50) NOT NULL DEFAULT ,
    [CdCompany] VARCHAR(20) NOT NULL DEFAULT ,
    [DirectDayProdPlanHeadName] NVARCHAR(500) NOT NULL DEFAULT ,
    [DayProdPlanUpdateStartYn] CHAR(1) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [UpdateDateTime] DATETIME NULL DEFAULT 
);
GO

