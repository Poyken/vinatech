CREATE TABLE [dbo].[STB_ManufacturingCostApplyInfo] (
    [ApplyDate] DATE NOT NULL DEFAULT ,
    [IsApply] BIT NOT NULL DEFAULT (CONVERT([bit],(0),0)),
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

