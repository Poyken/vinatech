CREATE TABLE [dbo].[STB_TechnicalPersonnelAttendanceInfo] (
    [AttendanceDate] DATE NOT NULL DEFAULT ,
    [WorkerCode] VARCHAR(20) NOT NULL DEFAULT ,
    [AttendanceDateTime] DATETIME NULL DEFAULT ,
    [LeavingDateTime] DATETIME NULL DEFAULT ,
    [IsConfirm] BIT NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    CONSTRAINT [PK_STB_TechnicalPersonnelAttendanceInfo] PRIMARY KEY CLUSTERED ([AttendanceDate], [WorkerCode])
);
GO

