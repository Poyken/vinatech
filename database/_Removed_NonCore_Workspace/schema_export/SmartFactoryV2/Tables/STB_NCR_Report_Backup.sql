CREATE TABLE [dbo].[STB_NCR_Report_Backup] (
    [NCRNo] VARCHAR(20) NOT NULL DEFAULT ,
    [JobDate] DATETIME NULL DEFAULT ,
    [CompanyCode] VARCHAR(20) NULL DEFAULT ,
    [OccurProcessCode] VARCHAR(20) NULL DEFAULT ,
    [MaterialName] VARCHAR(80) NULL DEFAULT ,
    [CustomName] VARCHAR(60) NULL DEFAULT ,
    [standardName] VARCHAR(60) NULL DEFAULT ,
    [LotNo] VARCHAR(80) NULL DEFAULT ,
    [Qty] INT NULL DEFAULT ,
    [InspectionQty] INT NULL DEFAULT ,
    [BadQty] INT NULL DEFAULT ,
    [PPM] INT NULL DEFAULT ,
    [InQty] INT NULL DEFAULT ,
    [BadLotQty] INT NULL DEFAULT ,
    [DefectiveRate] NUMERIC(5,2) NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [Nonconformity] NVARCHAR(4000) NULL DEFAULT ,
    [ImmediateAction] NVARCHAR(4000) NULL DEFAULT ,
    [CustomImmediateAction] NVARCHAR(4000) NULL DEFAULT ,
    [CustomCountermeasureImage] BIGINT NULL DEFAULT ,
    [IsActionCode] BIT NULL DEFAULT ,
    [EffectivenessCheck] BIT NULL DEFAULT ,
    [DefectImage] VARBINARY(MAX) NULL DEFAULT ,
    [DefectImage2] VARBINARY(MAX) NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT 
);
GO

