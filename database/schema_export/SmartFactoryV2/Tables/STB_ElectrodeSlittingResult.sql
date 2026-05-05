CREATE TABLE [dbo].[STB_ElectrodeSlittingResult] (
    [ElectrodeLotNumber] VARCHAR(20) NOT NULL DEFAULT ,
    [Seq] INT NOT NULL DEFAULT ,
    [ElectrodeThick] NUMERIC(20,5) NULL DEFAULT ,
    [SlittingWidth] NUMERIC(20,5) NULL DEFAULT ,
    [ProductionQty] NUMERIC(20,5) NULL DEFAULT ,
    [GoodQtyLength] NUMERIC(20,5) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    [LotUniqueNumber] BIGINT IDENTITY(1,1) NOT NULL DEFAULT ,
    [Barcode] VARCHAR(26) NULL DEFAULT ,
    [SlittingMaterialCode] VARCHAR(20) NULL DEFAULT ,
    [CompanyCode] VARCHAR(20) NULL DEFAULT ,
    [WorkCenterCode] VARCHAR(20) NULL DEFAULT ,
    [TransferDateTime] DATETIME NULL DEFAULT ,
    [SlittingKnifeLotID] VARCHAR(30) NULL DEFAULT ,
    CONSTRAINT [PK_STB_ElectrodeSlittingResult] PRIMARY KEY CLUSTERED ([ElectrodeLotNumber], [Seq])
);
GO

