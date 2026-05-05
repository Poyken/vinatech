CREATE TABLE [dbo].[STB_MachineRepairHistory] (
    [MachineRepairHistoryNo] VARCHAR(20) NOT NULL DEFAULT ,
    [CompanyCode] VARCHAR(20) NULL DEFAULT ,
    [WorkCenterCode] VARCHAR(20) NULL DEFAULT ,
    [MachineCode] VARCHAR(20) NULL DEFAULT ,
    [JobDate] DATE NULL DEFAULT ,
    [JobStartDateTime] DATETIME NULL DEFAULT ,
    [JobEndDateTime] DATETIME NULL DEFAULT ,
    [MachineLossHistNo] VARCHAR(20) NULL DEFAULT ,
    [TroublePoint] NVARCHAR(100) NULL DEFAULT ,
    [TroubleText] NVARCHAR(100) NULL DEFAULT ,
    [RepairText] NVARCHAR(200) NULL DEFAULT ,
    [IsMachineLoss] BIT NULL DEFAULT ,
    [TotalRepairCost] NUMERIC(20,5) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

