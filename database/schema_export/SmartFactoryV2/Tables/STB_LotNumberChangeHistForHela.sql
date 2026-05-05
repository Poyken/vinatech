CREATE TABLE [dbo].[STB_LotNumberChangeHistForHela] (
    [ControlNo] VARCHAR(20) NOT NULL DEFAULT ,
    [OldBarcode] VARCHAR(20) NULL DEFAULT ,
    [NewBarcode] VARCHAR(20) NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

