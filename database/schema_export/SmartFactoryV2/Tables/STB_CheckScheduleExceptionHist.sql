CREATE TABLE [dbo].[STB_CheckScheduleExceptionHist] (
    [LineCode] VARCHAR(20) NOT NULL DEFAULT ,
    [CheckScheduleExceptionDate] DATE NOT NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    [CheckScheduleExceptionStartDateTime] DATETIME NULL DEFAULT ,
    [CheckScheduleExceptionEndDateTime] DATETIME NULL DEFAULT ,
    CONSTRAINT [PK_STB_CheckScheduleExceptionHist] PRIMARY KEY CLUSTERED ([LineCode], [CheckScheduleExceptionDate])
);
GO

