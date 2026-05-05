CREATE TABLE [dbo].[STB_RevisionUpgradeLog] (
    [LogSeq] INT IDENTITY(1,1) NOT NULL DEFAULT ,
    [DocumentSaveCode] NVARCHAR(50) NOT NULL DEFAULT ,
    [MaterialCode] NVARCHAR(50) NOT NULL DEFAULT ,
    [OriginalRevision] NVARCHAR(20) NOT NULL DEFAULT ,
    [UpgradedRevision] NVARCHAR(20) NOT NULL DEFAULT ,
    [UpgradeReason] NVARCHAR(500) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT (getdate()),
    [CreateUserID] NVARCHAR(50) NULL DEFAULT 
);
GO

