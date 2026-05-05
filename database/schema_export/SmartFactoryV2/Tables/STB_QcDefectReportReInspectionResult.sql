CREATE TABLE [dbo].[STB_QcDefectReportReInspectionResult] (
    [DefectReportNo] VARCHAR(20) NOT NULL DEFAULT ,
    [DefectCode] VARCHAR(20) NOT NULL DEFAULT ,
    [InspectionQty] INT NULL DEFAULT ,
    [DefectQty] INT NULL DEFAULT ,
    [DefectRate] NUMERIC(27,13) NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    CONSTRAINT [PK_STB_QcDefectReportReInspectionResult] PRIMARY KEY CLUSTERED ([DefectReportNo], [DefectCode])
);
GO

