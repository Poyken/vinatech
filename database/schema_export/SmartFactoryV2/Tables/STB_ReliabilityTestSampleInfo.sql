CREATE TABLE [dbo].[STB_ReliabilityTestSampleInfo] (
    [RTSampleNo] VARCHAR(20) NOT NULL DEFAULT ,
    [RTRequestNo] VARCHAR(20) NULL DEFAULT ,
    [SampleLotNo] VARCHAR(20) NULL DEFAULT ,
    [TestItemCode] VARCHAR(20) NULL DEFAULT ,
    [VoltCondition] NUMERIC(5,1) NULL DEFAULT ,
    [TemperatureCondition] NUMERIC(5,1) NULL DEFAULT ,
    [HumidityCondition] NUMERIC(5,1) NULL DEFAULT ,
    [SampleQty] INT NULL DEFAULT ,
    [IsCapacity] BIT NULL DEFAULT ,
    [IsACEsr] BIT NULL DEFAULT ,
    [IsDCEsr] BIT NULL DEFAULT ,
    [IsSD] BIT NULL DEFAULT ,
    [IsLC] BIT NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    [VoltSpec] VARCHAR(10) NULL DEFAULT ,
    [FaradSpec] VARCHAR(10) NULL DEFAULT ,
    [IsWeight] BIT NULL DEFAULT ,
    [IsLength] BIT NULL DEFAULT ,
    [IsETC] VARCHAR(MAX) NULL DEFAULT 
);
GO

