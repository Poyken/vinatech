CREATE TABLE [dbo].[STB_DewpointData] (
    [ID] BIGINT IDENTITY(1,1) NOT NULL DEFAULT ,
    [LineCode] VARCHAR(20) NULL DEFAULT ,
    [Dewpoint] NUMERIC(20,5) NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate())
);
GO

