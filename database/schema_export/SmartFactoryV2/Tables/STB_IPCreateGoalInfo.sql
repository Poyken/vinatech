CREATE TABLE [dbo].[STB_IPCreateGoalInfo] (
    [EmployeeNo] VARCHAR(20) NOT NULL DEFAULT ,
    [IPClassCode] VARCHAR(20) NOT NULL DEFAULT ,
    [TargetQty] INT NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    [BaseYear] CHAR(4) NULL DEFAULT 
);
GO

