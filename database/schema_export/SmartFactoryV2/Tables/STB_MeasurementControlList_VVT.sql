CREATE TABLE [dbo].[STB_MeasurementControlList_VVT] (
    [ManagementNo] VARCHAR(50) NOT NULL DEFAULT ,
    [MeasurementNameE] NVARCHAR(100) NULL DEFAULT ,
    [MeasurementNameV] NVARCHAR(100) NULL DEFAULT ,
    [ModelName] NVARCHAR(100) NULL DEFAULT ,
    [Maker] NVARCHAR(100) NULL DEFAULT ,
    [Specification] NVARCHAR(100) NULL DEFAULT ,
    [SerialNo] VARCHAR(50) NULL DEFAULT ,
    [Status] NVARCHAR(30) NULL DEFAULT ,
    [SetLocation] NVARCHAR(100) NULL DEFAULT ,
    [Department] VARCHAR(50) NULL DEFAULT ,
    [WorkCenterCode] VARCHAR(10) NULL DEFAULT ,
    [PIC] NVARCHAR(50) NULL DEFAULT ,
    [DayOfCalibration] DATE NULL DEFAULT ,
    [ExpiredDate] DATE NULL DEFAULT ,
    [TypeOfCalibration] NVARCHAR(50) NULL DEFAULT ,
    [CertificateNo] NVARCHAR(50) NULL DEFAULT ,
    [CertificationBody] NVARCHAR(50) NULL DEFAULT ,
    [Remark] NVARCHAR(100) NULL DEFAULT ,
    [Note] NVARCHAR(MAX) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    [ProdProcessResultFile] BIGINT NULL DEFAULT 
);
GO

