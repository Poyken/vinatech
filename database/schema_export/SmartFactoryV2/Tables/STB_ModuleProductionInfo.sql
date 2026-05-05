CREATE TABLE [dbo].[STB_ModuleProductionInfo] (
    [ModuleProductionNo] VARCHAR(20) NOT NULL DEFAULT ,
    [JobStartDate] DATE NULL DEFAULT ,
    [SemiProdLotNo1] VARCHAR(20) NULL DEFAULT ,
    [SemiProdLotNo2] VARCHAR(20) NULL DEFAULT ,
    [PinHoleQty] NUMERIC(20,5) NULL DEFAULT ,
    [ChangeCellQty] NUMERIC(20,5) NULL DEFAULT ,
    [DefectRepairRemark] NVARCHAR(MAX) NULL DEFAULT ,
    [Farad] NUMERIC(20,5) NULL DEFAULT ,
    [ESR] NUMERIC(20,5) NULL DEFAULT ,
    [FinishedProdLotNo] VARCHAR(20) NULL DEFAULT ,
    [ShipmentDate] DATE NULL DEFAULT ,
    [ShipmentQty] NUMERIC(20,5) NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

