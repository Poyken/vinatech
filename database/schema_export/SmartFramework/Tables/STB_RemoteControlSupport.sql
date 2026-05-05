CREATE TABLE [dbo].[STB_RemoteControlSupport] (
    [SeqNo] BIGINT NOT NULL DEFAULT ,
    [RequestUserID] VARCHAR(20) NOT NULL DEFAULT ,
    [StartDateTime] DATETIME NULL DEFAULT ,
    [EndDateTime] DATETIME NULL DEFAULT ,
    [SupportUserID] VARCHAR(20) NULL DEFAULT ,
    [SupportContents] NVARCHAR(MAX) NULL DEFAULT 
);
GO

