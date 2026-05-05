CREATE TABLE [dbo].[STB_IoTCalibrationHist] (
    [DeviceID] VARCHAR(20) NOT NULL DEFAULT ,
    [CalibrationDate] DATE NOT NULL DEFAULT ,
    [StandardTemperature] NUMERIC(10,3) NULL DEFAULT ,
    [MeasureTemperature] NUMERIC(10,3) NULL DEFAULT ,
    [StandardHumidity] NUMERIC(10,3) NULL DEFAULT ,
    [MeasureHumidity] NUMERIC(10,3) NULL DEFAULT ,
    [InspectionWorkerCode] VARCHAR(20) NULL DEFAULT ,
    [IsCalibration] BIT NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    CONSTRAINT [PK_STB_IoTCalibrationHist] PRIMARY KEY CLUSTERED ([DeviceID], [CalibrationDate])
);
GO

