CREATE TABLE [dbo].[STB_PackingLabelHistForPS] (
    [PackingLabelHistNo] VARCHAR(20) NOT NULL DEFAULT ,
    [LotNo] VARCHAR(20) NULL DEFAULT ,
    [Voltage] VARCHAR(20) NULL DEFAULT ,
    [Farad] VARCHAR(20) NULL DEFAULT ,
    [Rating] VARCHAR(50) NULL DEFAULT ,
    [PartNo] VARCHAR(50) NULL DEFAULT ,
    [LotQty] INT NULL DEFAULT ,
    [LabelQty] INT NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

