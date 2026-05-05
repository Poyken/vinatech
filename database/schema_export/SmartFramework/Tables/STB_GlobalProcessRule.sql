CREATE TABLE [dbo].[STB_GlobalProcessRule] (
    [RuleCode] VARCHAR(50) NOT NULL DEFAULT ,
    [GroupName] NVARCHAR(50) NULL DEFAULT ,
    [RuleName] NVARCHAR(100) NULL DEFAULT ,
    [OptionDesc] NVARCHAR(MAX) NULL DEFAULT ,
    [SettingValue] VARCHAR(50) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

