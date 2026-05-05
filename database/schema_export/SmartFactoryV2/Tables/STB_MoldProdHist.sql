CREATE TABLE [dbo].[STB_MoldProdHist] (
    [MoldProdNo] VARCHAR(50) NOT NULL DEFAULT ,
    [CompanyCode] VARCHAR(20) NULL DEFAULT ,
    [WorkCenterCode] VARCHAR(20) NULL DEFAULT ,
    [JobDate] VARCHAR(20) NULL DEFAULT ,
    [ShiftCode] VARCHAR(20) NULL DEFAULT ,
    [StartDateTime] DATETIME NULL DEFAULT ,
    [ActStartDateTime] DATETIME NULL DEFAULT ,
    [ActEndDateTime] DATETIME NULL DEFAULT ,
    [DayPlanNo] VARCHAR(20) NULL DEFAULT ,
    [MachineCode] VARCHAR(20) NULL DEFAULT ,
    [MoldNumber] VARCHAR(20) NULL DEFAULT ,
    [WorkerCode] VARCHAR(20) NULL DEFAULT ,
    [ShotQty] INT NULL DEFAULT ,
    [PurgingWeight] NUMERIC(20,5) NULL DEFAULT 
);
GO

