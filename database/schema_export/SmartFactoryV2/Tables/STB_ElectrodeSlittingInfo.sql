CREATE TABLE [dbo].[STB_ElectrodeSlittingInfo] (
    [ElectrodeLotNumber] VARCHAR(20) NOT NULL DEFAULT ,
    [MachineCode] VARCHAR(20) NULL DEFAULT ,
    [WorkDate] DATETIME NULL DEFAULT ,
    [WorkerCode] VARCHAR(20) NULL DEFAULT ,
    [Temperature] NUMERIC(20,5) NULL DEFAULT ,
    [Humidity] NUMERIC(20,5) NULL DEFAULT ,
    [PushingYn] VARCHAR(10) NULL DEFAULT ,
    [VisualInspectionResult] VARCHAR(1000) NULL DEFAULT ,
    [SlittingLength] NUMERIC(20,5) NULL DEFAULT ,
    [Remark] VARCHAR(1000) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    [PrintYn] BIT NULL DEFAULT ,
    [PicturesLotNo] VARBINARY(MAX) NULL DEFAULT 
);
GO

