CREATE TABLE [dbo].[STB_IMSProcessInfo] (
    [PackingID] VARCHAR(20) NOT NULL DEFAULT ,
    [PickingQty] BIGINT NULL DEFAULT ,
    [BankLoc] INT NULL DEFAULT ,
    [LevelLoc] INT NULL DEFAULT ,
    [BayLoc] INT NULL DEFAULT ,
    [JobStartDateTime] DATETIME NULL DEFAULT ,
    [JobEndDateTime] DATETIME NULL DEFAULT ,
    [JobProcessResult] VARCHAR(100) NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NOT NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

