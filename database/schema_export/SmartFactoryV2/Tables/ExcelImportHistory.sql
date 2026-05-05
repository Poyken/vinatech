CREATE TABLE [dbo].[ExcelImportHistory] (
    [Id] INT IDENTITY(1,1) NOT NULL DEFAULT ,
    [FilePath] NVARCHAR(500) NOT NULL DEFAULT ,
    [FileSize] BIGINT NOT NULL DEFAULT ,
    [ImportedAt] DATETIME2 NOT NULL DEFAULT (sysdatetime()),
    [RowsInserted] INT NOT NULL DEFAULT ((0)),
    [Status] NVARCHAR(30) NOT NULL DEFAULT ,
    [ErrorMessage] NVARCHAR(MAX) NULL DEFAULT 
);
GO

