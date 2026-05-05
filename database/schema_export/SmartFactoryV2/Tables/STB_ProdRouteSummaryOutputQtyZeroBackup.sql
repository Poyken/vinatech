CREATE TABLE [dbo].[STB_ProdRouteSummaryOutputQtyZeroBackup] (
    [ProductSummaryID] VARCHAR(20) NOT NULL DEFAULT ,
    [CompanyCode] VARCHAR(20) NULL DEFAULT ,
    [WorkCenterCode] VARCHAR(20) NULL DEFAULT ,
    [JobDate] DATE NULL DEFAULT ,
    [ShiftCode] VARCHAR(1) NULL DEFAULT ,
    [TimeCode] VARCHAR(2) NULL DEFAULT ,
    [PONo] VARCHAR(20) NULL DEFAULT ,
    [MaterialCode] VARCHAR(20) NULL DEFAULT ,
    [LineCode] VARCHAR(20) NULL DEFAULT ,
    [RouteCode] VARCHAR(20) NULL DEFAULT ,
    [SubRouteCode] VARCHAR(20) NULL DEFAULT ,
    [MachineCode] VARCHAR(20) NULL DEFAULT ,
    [MoldNumber] VARCHAR(50) NULL DEFAULT ,
    [InputQty] NUMERIC(20,5) NULL DEFAULT ,
    [OutputQty] NUMERIC(20,5) NULL DEFAULT ,
    [DefectQty] NUMERIC(20,5) NULL DEFAULT ,
    [RepairQty] NUMERIC(20,5) NULL DEFAULT ,
    [LossQty] NUMERIC(20,5) NULL DEFAULT ,
    [BackFlushQty] NUMERIC(20,5) NULL DEFAULT 
);
GO

