CREATE TABLE [dbo].[STB_MaterialWarehouseInOutHist] (
    [MaterialWarehouseInOutHistNo] VARCHAR(20) NOT NULL DEFAULT ,
    [CompanyCode] VARCHAR(20) NULL DEFAULT ,
    [WorkCenterCode] VARCHAR(20) NULL DEFAULT ,
    [SourceMaterialWarehouseCode] VARCHAR(20) NOT NULL DEFAULT ,
    [TargetMaterialWarehouseCode] VARCHAR(20) NOT NULL DEFAULT ,
    [WarehouseInOutCode] VARCHAR(1) NULL DEFAULT ,
    [LotID] VARCHAR(500) NULL DEFAULT ,
    [WorkerCode] VARCHAR(20) NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    [LineCode] VARCHAR(20) NULL DEFAULT ,
    [ProcessedLotID] VARCHAR(20) NULL DEFAULT ,
    [Status_Confirm_Export] BIT NULL DEFAULT ,
    [ExportSlitingLength] NUMERIC(20,5) NULL DEFAULT ,
    [errorcontent] VARCHAR(255) NULL DEFAULT ,
    [ActualExportQuantity] NUMERIC(20,10) NULL DEFAULT ,
    [ProcessQty] NUMERIC(20,5) NULL DEFAULT 
);
GO

