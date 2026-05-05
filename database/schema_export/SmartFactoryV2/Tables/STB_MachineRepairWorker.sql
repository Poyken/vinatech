CREATE TABLE [dbo].[STB_MachineRepairWorker] (
    [MachineRepairWorkerCode] VARCHAR(20) NOT NULL DEFAULT ,
    [MachineRepairWorkerName] NVARCHAR(50) NULL DEFAULT ,
    [CompanyCode] VARCHAR(20) NULL DEFAULT ,
    [WorkCenterCode] VARCHAR(20) NULL DEFAULT ,
    [BasicCost] NUMERIC(15,2) NULL DEFAULT ,
    [IsUsed] BIT NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

