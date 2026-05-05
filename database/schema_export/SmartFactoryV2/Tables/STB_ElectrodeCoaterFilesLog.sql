CREATE TABLE [dbo].[STB_ElectrodeCoaterFilesLog] (
    [MachineName] VARCHAR(50) NULL DEFAULT ,
    [FilePath] NVARCHAR(1000) NULL DEFAULT ,
    [FileNameL] VARCHAR(255) NULL DEFAULT ,
    [ProcessedDate] DATETIME NULL DEFAULT (getdate())
);
GO

