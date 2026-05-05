CREATE TABLE [dbo].[STB_MasterProductionScheduleInfoHist] (
    [MasterProductionScheduleHistNo] BIGINT IDENTITY(1,1) NOT NULL DEFAULT ,
    [ActionMethodCode] VARCHAR(10) NULL DEFAULT ,
    [MasterProductionScheduleNo] VARCHAR(20) NOT NULL DEFAULT ,
    [BaseYearMonth] DATE NULL DEFAULT ,
    [SalesRegionCode] VARCHAR(20) NULL DEFAULT ,
    [SalesDate] DATE NULL DEFAULT ,
    [MaterialCode] VARCHAR(20) NULL DEFAULT ,
    [OrderTypeCode] VARCHAR(10) NULL DEFAULT ,
    [MaterialOrderQty] NUMERIC(20,4) NULL DEFAULT ,
    [CustomerCode] VARCHAR(20) NULL DEFAULT ,
    [ContactWorkerCode] VARCHAR(20) NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTIme] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

