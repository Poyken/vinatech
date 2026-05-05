CREATE TABLE [dbo].[STB_MediumSortingFilesLog] (
    [FileNameL] VARCHAR(255) NOT NULL DEFAULT ,
    [ProcessedDate] DATETIME NULL DEFAULT (getdate())
);
GO

