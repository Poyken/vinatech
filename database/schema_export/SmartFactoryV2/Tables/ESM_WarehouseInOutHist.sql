CREATE TABLE [dbo].[ESM_WarehouseInOutHist] (
    [WarehouseInOutHistNo] VARCHAR(20) NOT NULL DEFAULT ,
    [MaterialCode] VARCHAR(50) NOT NULL DEFAULT ,
    [WorkCenterCode] VARCHAR(20) NOT NULL DEFAULT ,
    [CdCompany] VARCHAR(20) NOT NULL DEFAULT ,
    [SourceMaterialWarehouseCode] VARCHAR(20) NULL DEFAULT ,
    [TargetMaterialWarehouseCode] VARCHAR(20) NULL DEFAULT ,
    [ProcessFixQty] NUMERIC(20,4) NULL DEFAULT ,
    [BasicDate] DATE NULL DEFAULT ,
    [LineCode] VARCHAR(20) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [ErpUpdate] NCHAR(1) NULL DEFAULT (N'N'),
    [ErpUpdateDateTime] DATETIME NULL DEFAULT ,
    [DirectSourceMaterialWarehouseCode] VARCHAR(20) NULL DEFAULT ,
    [DirectTargetMaterialWarehouseCode] VARCHAR(20) NULL DEFAULT ,
    [NoEmp] VARCHAR(20) NULL DEFAULT ,
    [UpdateDateTime] DATETIME NULL DEFAULT ,
    [UpdateNoEmp] VARCHAR(20) NULL DEFAULT ,
    CONSTRAINT [PK_ESM_WarehouseInOutHist] PRIMARY KEY CLUSTERED ([WarehouseInOutHistNo], [MaterialCode], [WorkCenterCode], [CdCompany])
);
GO

