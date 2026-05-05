CREATE TABLE [dbo].[STB_CheckScheduleInfo_20190903] (
    [CheckScheduleNo] VARCHAR(20) NOT NULL DEFAULT ,
    [CheckStandardNo] VARCHAR(20) NULL DEFAULT ,
    [CheckDate] DATE NULL DEFAULT ,
    [CheckTime] DATETIME NULL DEFAULT ,
    [CheckYn] BIT NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    [IsUsed] BIT NULL DEFAULT 
);
GO

