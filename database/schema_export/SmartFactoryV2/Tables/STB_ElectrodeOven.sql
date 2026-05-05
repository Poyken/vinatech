CREATE TABLE [dbo].[STB_ElectrodeOven] (
    [ProdCode] VARCHAR(20) NOT NULL DEFAULT ,
    [Seq] INT NOT NULL DEFAULT ,
    [DryingFurnaceName] VARCHAR(20) NULL DEFAULT ,
    [DryingFurnaceTemp] NUMERIC(20,5) NULL DEFAULT ,
    [DryingFurnaceAirUpperPart] NUMERIC(20,5) NULL DEFAULT ,
    [DryingFurnaceAirLowerPart] NUMERIC(20,5) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    [TempUpperTolerance] NUMERIC(20,5) NULL DEFAULT ,
    [TempLowerTolerance] NUMERIC(20,5) NULL DEFAULT ,
    [AirUpperTolerance] NUMERIC(20,5) NULL DEFAULT ,
    [AirLowerTolerance] NUMERIC(20,5) NULL DEFAULT ,
    CONSTRAINT [PK_STB_ElectrodeOven] PRIMARY KEY CLUSTERED ([ProdCode], [Seq])
);
GO

