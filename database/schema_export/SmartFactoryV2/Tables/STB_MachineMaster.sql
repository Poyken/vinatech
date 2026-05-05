CREATE TABLE [dbo].[STB_MachineMaster] (
    [MachineCode] VARCHAR(20) NOT NULL DEFAULT ,
    [CompanyCode] VARCHAR(20) NULL DEFAULT ,
    [WorkCenterCode] VARCHAR(20) NULL DEFAULT ,
    [MachineName] NVARCHAR(100) NULL DEFAULT ,
    [IsProdMachine] BIT NULL DEFAULT ,
    [MachineTypeCode] VARCHAR(20) NULL DEFAULT ,
    [IsUsed] BIT NULL DEFAULT ,
    [IsMonitoring] BIT NULL DEFAULT ,
    [MonitoringGroup] NVARCHAR(50) NULL DEFAULT ,
    [MachineRunStatus] VARCHAR(10) NULL DEFAULT ,
    [LossCode] VARCHAR(20) NULL DEFAULT ,
    [LossStartDateTime] DATETIME NULL DEFAULT ,
    [LossHistNo] VARCHAR(20) NULL DEFAULT ,
    [IsAlarm] BIT NULL DEFAULT ,
    [RunStartDateTime] DATETIME NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    [MachineNumber] NVARCHAR(50) NULL DEFAULT 
);
GO

