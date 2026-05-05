CREATE TABLE [dbo].[STB_MaterialCodeByLine] (
    [Idx] BIGINT IDENTITY(1,1) NOT NULL DEFAULT ,
    [LineCode] VARCHAR(20) NOT NULL DEFAULT ,
    [MaterialCode] VARCHAR(20) NOT NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate())
);
GO

