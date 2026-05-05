CREATE TABLE [dbo].[STB_RotaryKilnItemSpecInfo] (
    [RotaryKilnItemSpecNo] VARCHAR(20) NOT NULL DEFAULT ,
    [BaseDate] DATE NULL DEFAULT ,
    [MachineCode] VARCHAR(20) NULL DEFAULT ,
    [KilnTemperature] NUMERIC(20,5) NULL DEFAULT ,
    [RunTime] NUMERIC(20,5) NULL DEFAULT ,
    [SteamTemperature] NUMERIC(20,5) NULL DEFAULT ,
    [SpinSpeed] NUMERIC(20,5) NULL DEFAULT ,
    [WaterVaporPressure] NUMERIC(20,5) NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

