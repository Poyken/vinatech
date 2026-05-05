CREATE TABLE [dbo].[STB_MoldProductMonthlySummary] (
    [YearMonth] VARCHAR(6) NOT NULL DEFAULT ,
    [CompanyCode] VARCHAR(20) NOT NULL DEFAULT ,
    [WorkCenterCode] VARCHAR(20) NOT NULL DEFAULT ,
    [MoldNumber] VARCHAR(50) NOT NULL DEFAULT ,
    [MaterialCode] VARCHAR(50) NOT NULL DEFAULT ,
    [ProdQty] INT NULL DEFAULT ,
    CONSTRAINT [PK_STB_MoldProductMonthlySummary] PRIMARY KEY CLUSTERED ([YearMonth], [CompanyCode], [WorkCenterCode], [MoldNumber], [MaterialCode])
);
GO

