CREATE TABLE [dbo].[STB_WorkerTakeoverInfo] (
    [WorkerTakeoverNo] VARCHAR(20) NOT NULL DEFAULT ,
    [CompanyCode] VARCHAR(20) NOT NULL DEFAULT ,
    [WorkCenterCode] VARCHAR(20) NOT NULL DEFAULT ,
    [JobDate] DATE NOT NULL DEFAULT ,
    [TimeShiftCode] VARCHAR(10) NOT NULL DEFAULT ,
    [TakeoverContent] NVARCHAR(MAX) NOT NULL DEFAULT ,
    [WriteWorkerCode] VARCHAR(20) NOT NULL DEFAULT ,
    [WriteDateTime] DATETIME NOT NULL DEFAULT ,
    [IsConfirm] BIT NULL DEFAULT ,
    [ConfirmWorkerCode] VARCHAR(20) NULL DEFAULT ,
    [ConfirmDateTime] DATETIME NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    [TakeoverLineCode] VARCHAR(20) NULL DEFAULT 
);
GO

