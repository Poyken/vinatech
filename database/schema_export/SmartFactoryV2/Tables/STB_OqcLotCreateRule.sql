CREATE TABLE [dbo].[STB_OqcLotCreateRule] (
    [OqcCreateRuleNo] VARCHAR(20) NOT NULL DEFAULT ,
    [OqcCreateRuleName] NVARCHAR(50) NULL DEFAULT ,
    [CompanyCode] VARCHAR(20) NULL DEFAULT ,
    [WorkCenterCode] VARCHAR(20) NULL DEFAULT ,
    [ProdStartTime] VARCHAR(4) NULL DEFAULT ,
    [ProdEndTime] VARCHAR(4) NULL DEFAULT ,
    [IntervalHour] INT NULL DEFAULT ,
    [InspectionLevel] VARCHAR(20) NULL DEFAULT ,
    [AQL] NUMERIC(10,3) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

