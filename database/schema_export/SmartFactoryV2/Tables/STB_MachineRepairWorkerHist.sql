CREATE TABLE [dbo].[STB_MachineRepairWorkerHist] (
    [MachineRepairHistoryNo] VARCHAR(20) NOT NULL DEFAULT ,
    [MachineRepairWorkerSeq] INT NOT NULL DEFAULT ,
    [MachineRepairWorkerCode] VARCHAR(20) NULL DEFAULT ,
    [JobStartDateTime] DATETIME NULL DEFAULT ,
    [JobEndDateTime] DATETIME NULL DEFAULT ,
    [JobTime] INT NULL DEFAULT ,
    [BasicCost] NUMERIC(20,5) NULL DEFAULT ,
    [RepairText] NVARCHAR(400) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    CONSTRAINT [PK_STB_MachineRepairWorkerHist] PRIMARY KEY CLUSTERED ([MachineRepairHistoryNo], [MachineRepairWorkerSeq])
);
GO

