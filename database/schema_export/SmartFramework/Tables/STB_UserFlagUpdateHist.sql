CREATE TABLE [dbo].[STB_UserFlagUpdateHist] (
    [FlagUpdateHistNo] BIGINT IDENTITY(1,1) NOT NULL DEFAULT ,
    [UserID] VARCHAR(20) NULL DEFAULT ,
    [BefAllowFlag] VARCHAR(20) NULL DEFAULT ,
    [AftAllowFlag] VARCHAR(20) NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate())
);
GO

