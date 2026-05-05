CREATE TABLE [dbo].[SortingDataImportExcel] (
    [Id] INT IDENTITY(1,1) NOT NULL DEFAULT ,
    [EquipmentNumber] NVARCHAR(100) NULL DEFAULT ,
    [SorterNum] NVARCHAR(100) NULL DEFAULT ,
    [StartTime] DATETIME NULL DEFAULT ,
    [WorkflowCode] NVARCHAR(100) NULL DEFAULT ,
    [Barcode] NVARCHAR(100) NULL DEFAULT ,
    [Slot] NVARCHAR(10) NULL DEFAULT ,
    [Position] NVARCHAR(50) NULL DEFAULT ,
    [Channel] INT NULL DEFAULT ,
    [Capacity_mAh] NVARCHAR(50) NULL DEFAULT ,
    [Capacitance_F] NVARCHAR(50) NULL DEFAULT ,
    [BeginVoltageSD_mV] NVARCHAR(50) NULL DEFAULT ,
    [ChargeEndCurrent_mA] NVARCHAR(50) NULL DEFAULT ,
    [EndVoltage_mV] NVARCHAR(50) NULL DEFAULT ,
    [EndCurrent_mA] NVARCHAR(50) NULL DEFAULT ,
    [DischargeVoltage1_mV] NVARCHAR(50) NULL DEFAULT ,
    [DischargeVoltage1_Time] NVARCHAR(50) NULL DEFAULT ,
    [DischargeVoltage2_mV] NVARCHAR(50) NULL DEFAULT ,
    [DischargeVoltage2_Time] NVARCHAR(50) NULL DEFAULT ,
    [DischargeBeginVoltage_mV] NVARCHAR(50) NULL DEFAULT ,
    [DischargeBeginCurrent_mA] NVARCHAR(50) NULL DEFAULT ,
    [NGInfo] NVARCHAR(MAX) NULL DEFAULT ,
    [EndTime] DATETIME NULL DEFAULT ,
    [FilePath] NVARCHAR(500) NULL DEFAULT ,
    [ImportDate] DATETIME NULL DEFAULT (getdate())
);
GO

