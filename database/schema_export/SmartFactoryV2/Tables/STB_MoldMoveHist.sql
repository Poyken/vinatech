CREATE TABLE [dbo].[STB_MoldMoveHist] (
    [MoldMoveHistNo] VARCHAR(50) NOT NULL DEFAULT ,
    [CompanyCode] VARCHAR(20) NULL DEFAULT ,
    [WorkCenterCode] VARCHAR(20) NULL DEFAULT ,
    [MoldNumber] VARCHAR(20) NULL DEFAULT ,
    [MoveBasicDate] DATE NULL DEFAULT ,
    [MoldMoveTypeCode] VARCHAR(20) NULL DEFAULT ,
    [MoldLocationCode] VARCHAR(20) NULL DEFAULT ,
    [TargetWorkCenterCode] VARCHAR(20) NULL DEFAULT ,
    [ReturnBasicDate] DATE NULL DEFAULT ,
    [ManagerID] VARCHAR(20) NULL DEFAULT ,
    [MoveDesc] VARCHAR(200) NULL DEFAULT ,
    [MoveProcessDateTime] DATETIME NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

