CREATE TABLE [dbo].[ESM_DayProdPlanBatchLog] (
    [OrgDayPlanNo] VARCHAR(100) NOT NULL DEFAULT ,
    [BatchType] CHAR(1) NOT NULL DEFAULT ,
    [Method] VARCHAR(100) NOT NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT 
);
GO

