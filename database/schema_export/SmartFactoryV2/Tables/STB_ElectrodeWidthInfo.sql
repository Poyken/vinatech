CREATE TABLE [dbo].[STB_ElectrodeWidthInfo] (
    [ElectrodeWidth] NUMERIC(20,10) NOT NULL DEFAULT ,
    [ElectrodeCnt] INT NULL DEFAULT ((0)),
    [IsUsed] BIT NULL DEFAULT ((1)),
    [ElectrodeWidthLength] INT NULL DEFAULT ((0))
);
GO

