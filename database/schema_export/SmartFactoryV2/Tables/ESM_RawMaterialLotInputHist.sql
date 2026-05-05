CREATE TABLE [dbo].[ESM_RawMaterialLotInputHist] (
    [RawMaterialInputHistNo] VARCHAR(20) NOT NULL DEFAULT ,
    [RowHash] VARBINARY(150) NOT NULL DEFAULT ,
    [ORDERS] INT NOT NULL DEFAULT ,
    [MaterialCode] VARCHAR(50) NOT NULL DEFAULT ,
    [Barcode] VARCHAR(20) NOT NULL DEFAULT ,
    [WorkCenterCode] VARCHAR(20) NOT NULL DEFAULT ,
    [CompanyCode] VARCHAR(20) NOT NULL DEFAULT ,
    [CdCompany] VARCHAR(20) NULL DEFAULT ,
    [MaterialWarehouseCode] VARCHAR(20) NULL DEFAULT ,
    [LineCode] VARCHAR(20) NULL DEFAULT ,
    [LotID] VARCHAR(40) NULL DEFAULT ,
    [MaterialWarehouseName] NVARCHAR(100) NULL DEFAULT ,
    [WorkCenterName] NVARCHAR(100) NULL DEFAULT ,
    [MaterialName] VARCHAR(200) NULL DEFAULT ,
    [Qty] NUMERIC(20,4) NULL DEFAULT ,
    [UnitQty] NUMERIC(20,6) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    CONSTRAINT [PK_ESM_RawMaterialLotInputHist] PRIMARY KEY CLUSTERED ([RawMaterialInputHistNo], [RowHash], [ORDERS], [MaterialCode], [Barcode])
);
GO

