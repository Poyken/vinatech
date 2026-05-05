CREATE TABLE [dbo].[STB_MaterialQcSampleResult_BendingCutting] (
    [MaterialQcNo] VARCHAR(20) NOT NULL DEFAULT ,
    [MaterialQcDetailNo] INT NOT NULL DEFAULT ,
    [MaterialQcSampleNo] INT NOT NULL DEFAULT ,
    [SampleSerialNo] VARCHAR(50) NULL DEFAULT ,
    [TestUserID] VARCHAR(20) NULL DEFAULT ,
    [TestDateTime] DATETIME NULL DEFAULT ,
    [TestValue] NUMERIC(20,5) NULL DEFAULT ,
    [TestResult] VARCHAR(10) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    [MeasureDate] VARCHAR(10) NULL DEFAULT 
);
GO

