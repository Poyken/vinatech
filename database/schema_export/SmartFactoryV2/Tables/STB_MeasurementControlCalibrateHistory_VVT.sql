CREATE TABLE [dbo].[STB_MeasurementControlCalibrateHistory_VVT] (
    [ID] INT IDENTITY(1,1) NOT NULL DEFAULT ,
    [ManagementNo] VARCHAR(50) NULL DEFAULT ,
    [SerialNo] VARCHAR(50) NULL DEFAULT ,
    [DayOfCalibration] DATE NULL DEFAULT ,
    [Remark] NVARCHAR(100) NULL DEFAULT ,
    [Note] NVARCHAR(MAX) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

