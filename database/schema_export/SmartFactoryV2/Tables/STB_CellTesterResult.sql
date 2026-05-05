CREATE TABLE [dbo].[STB_CellTesterResult] (
    [MachineCode] VARCHAR(20) NOT NULL DEFAULT ,
    [Barcode] VARCHAR(20) NOT NULL DEFAULT ,
    [MeasureClassCode] VARCHAR(10) NOT NULL DEFAULT ,
    [ChannelCode] VARCHAR(20) NOT NULL DEFAULT ,
    [MeasureIndex] INT NOT NULL DEFAULT ,
    [MeasureTime] NUMERIC(10,1) NOT NULL DEFAULT ,
    [MeasureVoltage] NUMERIC(10,5) NULL DEFAULT ,
    [MeasureCurrent] NUMERIC(10,5) NULL DEFAULT ,
    [MeasureResistance] NUMERIC(10,5) NULL DEFAULT ,
    [MeasureCharge] NUMERIC(10,5) NULL DEFAULT ,
    [MeasureDisCharge] NUMERIC(10,5) NULL DEFAULT ,
    [MeasureOCV] NUMERIC(10,5) NULL DEFAULT ,
    [MeasureDCIR] NUMERIC(10,5) NULL DEFAULT ,
    CONSTRAINT [PK_STB_CellTesterResult] PRIMARY KEY CLUSTERED ([MachineCode], [Barcode], [MeasureClassCode], [ChannelCode], [MeasureIndex], [MeasureTime])
);
GO

