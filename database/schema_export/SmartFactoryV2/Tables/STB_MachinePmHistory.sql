CREATE TABLE [dbo].[STB_MachinePmHistory] (
    [MachinePmHistoryNo] VARCHAR(20) NOT NULL DEFAULT ,
    [MachinePmItemCode] VARCHAR(20) NULL DEFAULT ,
    [CompanyCode] VARCHAR(20) NULL DEFAULT ,
    [WorkCenterCode] VARCHAR(20) NULL DEFAULT ,
    [MachineCode] VARCHAR(20) NULL DEFAULT ,
    [JobDate] DATE NULL DEFAULT ,
    [MachineRepairWorkerCode] VARCHAR(20) NULL DEFAULT ,
    [PmDateTime] DATETIME NULL DEFAULT ,
    [PmText] NVARCHAR(100) NULL DEFAULT ,
    [IsFinishPm] BIT NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    [MachinePmResultReportFileID] BIGINT NULL DEFAULT 
);
GO

