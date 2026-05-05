CREATE TABLE [dbo].[STB_ApprovalLineInfo] (
    [ProcessViewName] VARCHAR(50) NOT NULL DEFAULT ,
    [ApprovalStepID] INT NOT NULL DEFAULT ,
    [ApprovalStepName] VARCHAR(50) NOT NULL DEFAULT ,
    [ProcessUserID] VARCHAR(20) NOT NULL DEFAULT ,
    [Email] VARCHAR(100) NULL DEFAULT ,
    [PhoneNumber] VARCHAR(50) NULL DEFAULT ,
    [CallBackID] INT NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NOT NULL DEFAULT ('eai'),
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

