CREATE TABLE [dbo].[STB_EAWorkInfo] (
    [EAWorkNo] VARCHAR(20) NOT NULL DEFAULT ,
    [RequestContent] VARCHAR(4000) NULL DEFAULT ,
    [RequestDeptCode] VARCHAR(20) NULL DEFAULT ,
    [RequestWorkerCode] VARCHAR(20) NULL DEFAULT ,
    [RequestDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [DueDate] DATETIME NULL DEFAULT ,
    [ProcessingWorkerCode] VARCHAR(20) NULL DEFAULT ,
    [FinishDateTime] DATETIME NULL DEFAULT ,
    [IsFinish] BIT NOT NULL DEFAULT ((0)),
    [Remark] VARCHAR(4000) NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    [RequestMenuPath] NVARCHAR(500) NULL DEFAULT ,
    [ProcessingContent] NVARCHAR(MAX) NULL DEFAULT 
);
GO

