CREATE TABLE [dbo].[STB_ProdRouteSummary_NEW] (
    [JobDate] DATE NULL DEFAULT ,
    [MaterialCode] VARCHAR(20) NULL DEFAULT ,
    [MaterialName] VARCHAR(100) NULL DEFAULT ,
    [TotalQty] NUMERIC(20,5) NULL DEFAULT ,
    [OutputQty] NUMERIC(20,5) NULL DEFAULT ,
    [DefectQty] NUMERIC(20,5) NULL DEFAULT ,
    [LossQty] NUMERIC(20,5) NULL DEFAULT ,
    [TotalRate] NUMERIC(20,5) NULL DEFAULT ,
    [LineCode] VARCHAR(20) NULL DEFAULT ,
    [RouteCode] VARCHAR(20) NULL DEFAULT 
);
GO

