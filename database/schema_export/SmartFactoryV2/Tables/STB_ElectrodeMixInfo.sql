CREATE TABLE [dbo].[STB_ElectrodeMixInfo] (
    [ElectrodeLotNumber] VARCHAR(20) NOT NULL DEFAULT ,
    [MachineCode] VARCHAR(20) NULL DEFAULT ,
    [WorkDate] DATETIME NULL DEFAULT ,
    [WorkerCode] VARCHAR(20) NULL DEFAULT ,
    [Temperature] NUMERIC(20,5) NULL DEFAULT ,
    [Humidity] NUMERIC(20,5) NULL DEFAULT ,
    [ProductionQty] NUMERIC(20,5) NULL DEFAULT ,
    [TankInsideTemp] NUMERIC(20,5) NULL DEFAULT ,
    [ViscosityValue] NUMERIC(20,5) NULL DEFAULT ,
    [SpecificGravityValue] NUMERIC(20,5) NULL DEFAULT ,
    [MixingTemperature] NUMERIC(20,5) NULL DEFAULT ,
    [SpecificComment] VARCHAR(1000) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    [CoolantTemperature] NUMERIC(20,5) NULL DEFAULT ,
    [ViscosityResult] VARCHAR(2) NOT NULL DEFAULT 
);
GO

