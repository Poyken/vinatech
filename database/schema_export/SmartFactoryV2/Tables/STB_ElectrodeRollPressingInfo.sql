CREATE TABLE [dbo].[STB_ElectrodeRollPressingInfo] (
    [ElectrodeLotNumber] VARCHAR(20) NOT NULL DEFAULT ,
    [MachineCode] VARCHAR(20) NULL DEFAULT ,
    [WorkDate] DATETIME NULL DEFAULT ,
    [WorkerCode] VARCHAR(20) NULL DEFAULT ,
    [Temperature] NUMERIC(20,5) NULL DEFAULT ,
    [Humidity] NUMERIC(20,5) NULL DEFAULT ,
    [RollingDensityValue] NUMERIC(20,5) NULL DEFAULT ,
    [RollingDensityResult] VARCHAR(10) NULL DEFAULT ,
    [HeadGapInitLeft] VARCHAR(10) NULL DEFAULT ,
    [HeadGapInitRight] VARCHAR(10) NULL DEFAULT ,
    [ProdConTemp] NUMERIC(20,5) NULL DEFAULT ,
    [ProdConSpeed] NUMERIC(20,5) NULL DEFAULT ,
    [ProductionQty] NUMERIC(20,5) NULL DEFAULT ,
    [GoodQty] NUMERIC(20,5) NULL DEFAULT ,
    [BadQty] NUMERIC(20,5) NULL DEFAULT ,
    [VisualInspectionResult] VARCHAR(1000) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    [PrintYn] BIT NULL DEFAULT 
);
GO

