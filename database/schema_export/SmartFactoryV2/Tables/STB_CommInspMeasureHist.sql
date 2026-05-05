CREATE TABLE [dbo].[STB_CommInspMeasureHist] (
    [CommInspMeasureNo] VARCHAR(20) NOT NULL DEFAULT ,
    [CommInspDocItemNo] VARCHAR(20) NULL DEFAULT ,
    [MeasureSeq] INT NULL DEFAULT ,
    [TextMeasure] VARCHAR(50) NULL DEFAULT ,
    [NumericMeasure] NUMERIC(20,5) NULL DEFAULT ,
    [MeasureResult] VARCHAR(4) NULL DEFAULT ,
    [MeasureDateTime] DATETIME NULL DEFAULT ,
    [MeasureUserID] VARCHAR(20) NULL DEFAULT ,
    [ErrorField] VARCHAR(10) NULL DEFAULT ,
    [InspWorkerCode] VARCHAR(20) NULL DEFAULT 
);
GO

