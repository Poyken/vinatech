CREATE TABLE [dbo].[STB_PackingLabelPrintHist] (
    [PackingID] VARCHAR(20) NOT NULL DEFAULT ,
    [PrintCount] INT NOT NULL DEFAULT ((1)),
    [IsPrintAllow] BIT NOT NULL DEFAULT (CONVERT([bit],(0),0)),
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NOT NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

