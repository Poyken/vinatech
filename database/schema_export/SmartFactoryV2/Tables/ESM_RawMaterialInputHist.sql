CREATE TABLE [dbo].[ESM_RawMaterialInputHist] (
    [DayPlanNo] VARCHAR(20) NOT NULL DEFAULT ,
    [OrgDayPlanNo] VARCHAR(20) NOT NULL DEFAULT ,
    [MaterialCode] VARCHAR(50) NOT NULL DEFAULT ,
    [WorkCenterCode] VARCHAR(20) NOT NULL DEFAULT ,
    [CdCompany] VARCHAR(20) NOT NULL DEFAULT ,
    [MaterialName] VARCHAR(300) NULL DEFAULT ,
    [MaterialUnit] VARCHAR(10) NULL DEFAULT ,
    [MaterialUsed] CHAR(1) NULL DEFAULT ,
    [MaterialTypeCode] VARCHAR(20) NULL DEFAULT ,
    [SourceMaterialWarehouseCode] VARCHAR(20) NULL DEFAULT ,
    [TargetMaterialWarehouseCode] VARCHAR(20) NULL DEFAULT ,
    [SourceMaterialWarehouseName] NVARCHAR(100) NULL DEFAULT ,
    [TargetMaterialWarehouseName] NVARCHAR(100) NULL DEFAULT ,
    [Qty] NUMERIC(20,4) NULL DEFAULT ,
    [UsedQty] NUMERIC(20,6) NULL DEFAULT ,
    [ProdQty] NUMERIC(20,4) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [Barcode] VARCHAR(100) NULL DEFAULT 
);
GO

