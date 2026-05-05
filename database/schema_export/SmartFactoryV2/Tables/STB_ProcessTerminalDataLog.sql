CREATE TABLE [dbo].[STB_ProcessTerminalDataLog] (
    [ProcessIndex] BIGINT IDENTITY(1,1) NOT NULL DEFAULT ,
    [IPAddress] VARCHAR(15) NULL DEFAULT ,
    [PortNo] INT NULL DEFAULT ,
    [Data] VARCHAR(MAX) NULL DEFAULT ,
    [ProcessResult] VARCHAR(MAX) NULL DEFAULT ,
    [ProcessDateTime] DATETIME NULL DEFAULT ,
    [EventDateTime] DATETIME NULL DEFAULT 
);
GO

