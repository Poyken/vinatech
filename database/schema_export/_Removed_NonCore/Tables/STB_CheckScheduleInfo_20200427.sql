CREATE TABLE [dbo].[STB_CheckScheduleInfo_20200427] (
    [CheckScheduleNo] VARCHAR(20) NOT NULL DEFAULT ,
    [CheckStandardNo] VARCHAR(20) NULL DEFAULT ,
    [CheckDate] DATE NULL DEFAULT ,
    [CheckTime] DATETIME NULL DEFAULT ,
    [CheckYn] BIT NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    [IsUsed] BIT NULL DEFAULT ,
    [OccasionalCheckItemName] VARCHAR(100) NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT 
);
GO

