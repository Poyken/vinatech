CREATE TABLE [dbo].[STB_VisionInspectionResult] (
    [ResultNo] BIGINT IDENTITY(1,1) NOT NULL DEFAULT ,
    [MachineID] VARCHAR(20) NULL DEFAULT ,
    [LotNo] VARCHAR(20) NULL DEFAULT ,
    [Barcode] VARCHAR(20) NULL DEFAULT ,
    [ModelNo] VARCHAR(50) NULL DEFAULT ,
    [PannelID] VARCHAR(100) NULL DEFAULT ,
    [DecisionResult] VARCHAR(10) NULL DEFAULT ,
    [DefectNo] NUMERIC(20,5) NULL DEFAULT ,
    [DotBlackType] NUMERIC(20,5) NULL DEFAULT ,
    [LineBlackType] NUMERIC(20,5) NULL DEFAULT ,
    [MuraBlackType] NUMERIC(20,5) NULL DEFAULT ,
    [DotWhiteType] NUMERIC(20,5) NULL DEFAULT ,
    [LineWhiteType] NUMERIC(20,5) NULL DEFAULT ,
    [MuraWhiteType] NUMERIC(20,5) NULL DEFAULT ,
    [ExtenedType] NUMERIC(20,5) NULL DEFAULT ,
    [etc] NUMERIC(20,5) NULL DEFAULT ,
    [DecisionDateTime] DATETIME NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT (getdate()),
    [Pitch] VARCHAR(100) NULL DEFAULT ,
    [SheetSize] VARCHAR(200) NULL DEFAULT 
);
GO

