CREATE TABLE [dbo].[STB_DefectRepairPartInfo] (
    [DefectRepairPartSeqNo] BIGINT IDENTITY(1,1) NOT NULL DEFAULT ,
    [DefectSummaryNo] VARCHAR(20) NOT NULL DEFAULT ,
    [DefectSummaryDetailNo] VARCHAR(20) NULL DEFAULT ,
    [MaterialCode] VARCHAR(50) NULL DEFAULT ,
    [DefectCauseType] VARCHAR(20) NULL DEFAULT ,
    [DutyCostCenterCode] VARCHAR(20) NULL DEFAULT ,
    [DutyVendorCode] VARCHAR(20) NULL DEFAULT ,
    [DefectCode] VARCHAR(20) NULL DEFAULT ,
    [DefectCauseCode] VARCHAR(20) NULL DEFAULT ,
    [DefectCauseDesc] NVARCHAR(200) NULL DEFAULT ,
    [LossQty] NUMERIC(20,5) NULL DEFAULT ,
    [IsChangeMaterial] BIT NULL DEFAULT ,
    [ChangePartBarcode] VARCHAR(50) NULL DEFAULT ,
    [ChangePartSerial] VARCHAR(50) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

