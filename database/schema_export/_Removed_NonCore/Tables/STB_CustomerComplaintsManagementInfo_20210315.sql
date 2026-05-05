CREATE TABLE [dbo].[STB_CustomerComplaintsManagementInfo_20210315] (
    [CustomerComplaintsManagementNo] VARCHAR(20) NOT NULL DEFAULT ,
    [ReceiptDate] DATE NULL DEFAULT ,
    [CustomerCode] VARCHAR(20) NULL DEFAULT ,
    [MaterialCode] VARCHAR(20) NULL DEFAULT ,
    [ProductSize] VARCHAR(20) NULL DEFAULT ,
    [CustomerComplaintsDefectTypeCode] VARCHAR(20) NULL DEFAULT ,
    [ProductionCompanyCode] VARCHAR(20) NULL DEFAULT ,
    [CustomerComplaintsContents] NVARCHAR(MAX) NULL DEFAULT ,
    [Barcode] NVARCHAR(1000) NULL DEFAULT ,
    [MarkingLetter] NVARCHAR(1000) NULL DEFAULT ,
    [DefectQty] NUMERIC(10,2) NULL DEFAULT ,
    [ResponsibilityCompanyCode] VARCHAR(20) NULL DEFAULT ,
    [CustomerComplaintsDefectCode] VARCHAR(20) NULL DEFAULT ,
    [CauseContents] NVARCHAR(MAX) NULL DEFAULT ,
    [ActionContents] NVARCHAR(MAX) NULL DEFAULT ,
    [ActionDocSubmissionDate] DATETIME NULL DEFAULT ,
    [ActionDocFileID] BIGINT NULL DEFAULT ,
    [CreateDateTime] DATE NOT NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    [IsPerformance] BIT NOT NULL DEFAULT 
);
GO

