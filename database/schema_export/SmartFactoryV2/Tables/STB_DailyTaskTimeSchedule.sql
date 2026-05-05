CREATE TABLE [dbo].[STB_DailyTaskTimeSchedule] (
    [TaskIndex] INT NOT NULL DEFAULT ,
    [StartTime] TIME NULL DEFAULT ,
    [EndTime] TIME NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NOT NULL DEFAULT ('eai'),
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

