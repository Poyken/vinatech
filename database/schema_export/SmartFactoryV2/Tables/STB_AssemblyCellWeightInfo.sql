CREATE TABLE [dbo].[STB_AssemblyCellWeightInfo] (
    [Idx] BIGINT IDENTITY(1,1) NOT NULL DEFAULT ,
    [LineCode] VARCHAR(20) NULL DEFAULT ,
    [CellWeight] NUMERIC(20,5) NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate())
);
GO

