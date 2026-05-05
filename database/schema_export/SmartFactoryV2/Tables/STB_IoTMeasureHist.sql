CREATE TABLE [dbo].[STB_IoTMeasureHist] (
    [MeasureNo] VARCHAR(20) NOT NULL DEFAULT ,
    [DeviceID] VARCHAR(20) NOT NULL DEFAULT ,
    [MeasureItemCode] VARCHAR(20) NOT NULL DEFAULT ,
    [MeasureValue] NUMERIC(20,3) NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

