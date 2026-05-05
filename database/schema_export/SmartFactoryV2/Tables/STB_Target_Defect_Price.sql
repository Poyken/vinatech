CREATE TABLE [dbo].[STB_Target_Defect_Price] (
    [TargetDefectPrice] INT NULL DEFAULT ,
    [CompanyCode] VARCHAR(20) NOT NULL DEFAULT ,
    [LineCode] VARCHAR(20) NOT NULL DEFAULT ,
    CONSTRAINT [PK_STB_Target_Defect_Price] PRIMARY KEY CLUSTERED ([CompanyCode], [LineCode])
);
GO

