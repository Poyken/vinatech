CREATE TABLE [dbo].[STB_DayWorkGroup] (
    [CompanyCode] VARCHAR(20) NOT NULL DEFAULT ,
    [WorkCenterCode] VARCHAR(20) NOT NULL DEFAULT ,
    [JobDate] DATE NOT NULL DEFAULT ,
    [WorkerCode] VARCHAR(20) NOT NULL DEFAULT ,
    [WorkGroupCode] VARCHAR(20) NULL DEFAULT ,
    [WorkGroupName] VARCHAR(20) NULL DEFAULT ,
    [ShiftCode] VARCHAR(20) NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NOT NULL DEFAULT ('eai'),
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    CONSTRAINT [PK_STB_DayWorkGroup] PRIMARY KEY CLUSTERED ([CompanyCode], [WorkCenterCode], [JobDate], [WorkerCode])
);
GO

