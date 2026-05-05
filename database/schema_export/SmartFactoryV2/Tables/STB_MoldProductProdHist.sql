CREATE TABLE [dbo].[STB_MoldProductProdHist] (
    [MoldProdNo] VARCHAR(50) NOT NULL DEFAULT ,
    [MaterialCode] VARCHAR(50) NOT NULL DEFAULT ,
    [CompanyCode] VARCHAR(20) NULL DEFAULT ,
    [WorkCenterCode] VARCHAR(20) NULL DEFAULT ,
    [ProdQty] INT NULL DEFAULT ,
    [DefectQty] INT NULL DEFAULT ,
    [TryQty] INT NULL DEFAULT ,
    [Cabity] INT NULL DEFAULT ,
    [IsProduct] VARCHAR(1) NULL DEFAULT ,
    [GoodUpdatingStockQty] INT NULL DEFAULT ,
    [DefectUpdatingStockQty] INT NULL DEFAULT ,
    [GoodAppliedStockQty] INT NULL DEFAULT ,
    [DefectAppliedStockQty] INT NULL DEFAULT ,
    CONSTRAINT [PK_STB_MoldProductProdHist] PRIMARY KEY CLUSTERED ([MoldProdNo], [MaterialCode])
);
GO

