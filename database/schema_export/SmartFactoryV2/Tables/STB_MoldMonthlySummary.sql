CREATE TABLE [dbo].[STB_MoldMonthlySummary] (
    [YearMonth] VARCHAR(6) NOT NULL DEFAULT ,
    [CompanyCode] VARCHAR(20) NOT NULL DEFAULT ,
    [WorkCenterCode] VARCHAR(20) NOT NULL DEFAULT ,
    [MoldNumber] VARCHAR(50) NOT NULL DEFAULT ,
    [ShotQty] INT NULL DEFAULT ,
    CONSTRAINT [PK_STB_MoldMonthlySummary] PRIMARY KEY CLUSTERED ([YearMonth], [CompanyCode], [WorkCenterCode], [MoldNumber])
);
GO

