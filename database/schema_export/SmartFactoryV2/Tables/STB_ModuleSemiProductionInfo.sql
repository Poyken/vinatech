CREATE TABLE [dbo].[STB_ModuleSemiProductionInfo] (
    [ModuleSemiProductionNo] VARCHAR(20) NOT NULL DEFAULT ,
    [ProdDate] DATE NULL DEFAULT ,
    [Grade] VARCHAR(10) NULL DEFAULT ,
    [PCBLotNo] VARCHAR(20) NULL DEFAULT ,
    [SemiProdLotNo] VARCHAR(20) NULL DEFAULT ,
    [SingleCellLotNo1] VARCHAR(20) NULL DEFAULT ,
    [SingleCellLotNo2] VARCHAR(20) NULL DEFAULT ,
    [SingleCellLotNo3] VARCHAR(20) NULL DEFAULT ,
    [Remark] NVARCHAR(MAX) NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

