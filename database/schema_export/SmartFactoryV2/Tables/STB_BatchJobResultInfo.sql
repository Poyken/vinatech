CREATE TABLE [dbo].[STB_BatchJobResultInfo] (
    [idx] BIGINT IDENTITY(1,1) NOT NULL DEFAULT ,
    [ResultString] NVARCHAR(MAX) NULL DEFAULT ,
    [BatchJobResultType] CHAR(1) NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate())
);
GO

