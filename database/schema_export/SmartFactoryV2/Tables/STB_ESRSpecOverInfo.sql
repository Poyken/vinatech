CREATE TABLE [dbo].[STB_ESRSpecOverInfo] (
    [BaseDate] DATE NOT NULL DEFAULT ,
    [LineCode] VARCHAR(20) NOT NULL DEFAULT ,
    [Seq] INT NOT NULL DEFAULT ,
    [CheckStartDateTime] DATETIME NOT NULL DEFAULT ,
    [CheckEndDateTime] DATETIME NULL DEFAULT ,
    [SpecOverCount] INT NOT NULL DEFAULT ((0)),
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [LastCheckDateTime] DATETIME NULL DEFAULT ,
    CONSTRAINT [PK_STB_ESRSpecOverInfo] PRIMARY KEY CLUSTERED ([BaseDate], [LineCode], [Seq])
);
GO

