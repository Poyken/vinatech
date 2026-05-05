CREATE TABLE [dbo].[STB_UnitConverter] (
    [TargetUnit] VARCHAR(20) NOT NULL DEFAULT ,
    [BaseUnit] VARCHAR(20) NULL DEFAULT ,
    [ConvertRate] NUMERIC(38,19) NULL DEFAULT ,
    [UnitType] VARCHAR(20) NULL DEFAULT 
);
GO

