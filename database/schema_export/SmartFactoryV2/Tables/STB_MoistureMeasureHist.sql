CREATE TABLE [dbo].[STB_MoistureMeasureHist] (
    [MoistureMeasureHistNo] VARCHAR(20) NOT NULL DEFAULT ,
    [MeasureDate] DATE NULL DEFAULT ,
    [TimeShiftCode] INT NULL DEFAULT ,
    [InspWorkerCode] VARCHAR(20) NULL DEFAULT ,
    [CompanyCode] VARCHAR(20) NULL DEFAULT ,
    [WorkCenterCode] VARCHAR(20) NULL DEFAULT ,
    [LineCode] VARCHAR(20) NULL DEFAULT ,
    [MachineCode] VARCHAR(20) NULL DEFAULT ,
    [SpecificComment] NVARCHAR(MAX) NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    [SampleWeight] NUMERIC(20,5) NULL DEFAULT ,
    [KarlFischerImageFileID] BIGINT NULL DEFAULT 
);
GO

