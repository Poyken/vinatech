CREATE TABLE [dbo].[STB_Vietnam_ESRgrowup_dayByday] (
    [id] INT IDENTITY(1,1) NOT NULL DEFAULT ,
    [LotNo] VARCHAR(50) NOT NULL DEFAULT ,
    [Farad] VARCHAR(10) NULL DEFAULT ,
    [productdate] DATETIME NULL DEFAULT ,
    [prodqty] NUMERIC(10,0) NULL DEFAULT ,
    [ESR_OQC_Date] DATETIME NULL DEFAULT ,
    [ESR_Result] VARCHAR(10) NULL DEFAULT ,
    [modelcode] VARCHAR(30) NULL DEFAULT ,
    [modelname] VARCHAR(200) NULL DEFAULT ,
    [ESR_TQC_Date] DATETIME NULL DEFAULT ,
    [T_ESR_Result] NUMERIC(20,5) NULL DEFAULT ,
    [InternalSpec] NUMERIC(10,2) NULL DEFAULT ,
    [EstimatedArivalDateofIS] DATETIME NULL DEFAULT ,
    [CustomerSpec] NUMERIC(10,2) NULL DEFAULT ,
    [EstimatedArivalDateofCS] DATETIME NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT (getdate()),
    [CreateUserId] VARCHAR(20) NULL DEFAULT ,
    [MaterialQcSampleNo] INT NULL DEFAULT ,
    [MaterialQcDetailNo] INT NULL DEFAULT 
);
GO

