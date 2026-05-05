CREATE TABLE [dbo].[ExcelImportHistory_test] (
    [Id] INT IDENTITY(1,1) NOT NULL DEFAULT ,
    [FilePath] NVARCHAR(500) NULL DEFAULT ,
    [FileSize] BIGINT NULL DEFAULT ,
    [ImportedAt] DATETIME2 NULL DEFAULT (getdate()),
    [RowsInserted] INT NULL DEFAULT ,
    [Status] NVARCHAR(30) NULL DEFAULT ,
    [ErrorMessage] NVARCHAR(MAX) NULL DEFAULT 
);
GO

