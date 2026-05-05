CREATE TABLE [dbo].[STB_DailyTaskInfo] (
    [UserID] VARCHAR(20) NOT NULL DEFAULT ,
    [TaskDate] DATETIME NOT NULL DEFAULT ,
    [TaskIndex] INT NOT NULL DEFAULT ,
    [TaskContent] VARCHAR(2000) NULL DEFAULT ,
    [CompletionDate] DATETIME NULL DEFAULT ,
    [FinishedDate] DATETIME NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    CONSTRAINT [PK_STB_DailyTaskInfo] PRIMARY KEY CLUSTERED ([UserID], [TaskDate], [TaskIndex])
);
GO

