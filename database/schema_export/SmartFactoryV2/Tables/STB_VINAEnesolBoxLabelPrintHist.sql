CREATE TABLE [dbo].[STB_VINAEnesolBoxLabelPrintHist] (
    [VINAEnesolBoxLabelPrintHistNo] VARCHAR(20) NOT NULL DEFAULT ,
    [MaterialCode] VARCHAR(20) NULL DEFAULT ,
    [ProdDate] DATE NULL DEFAULT ,
    [ProdWeek] VARCHAR(50) NULL DEFAULT ,
    [LastLotNo] VARCHAR(50) NULL DEFAULT ,
    [ProdMachineCode] VARCHAR(50) NULL DEFAULT ,
    [ProdLocationCode] VARCHAR(50) NULL DEFAULT ,
    [PackingQty] INT NULL DEFAULT ,
    [LabelQty] INT NULL DEFAULT ,
    [CustomerPartNo] VARCHAR(50) NULL DEFAULT ,
    [LotNo] VARCHAR(10) NULL DEFAULT ,
    [LabelClassCode] VARCHAR(20) NULL DEFAULT ,
    [ModelSpec] VARCHAR(50) NULL DEFAULT ,
    [SerialNo] VARCHAR(3) NULL DEFAULT ,
    [Barcode] VARCHAR(50) NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

