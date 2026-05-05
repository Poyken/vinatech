CREATE TABLE [dbo].[STB_MaterialQcInspectionItem_BendingCutting] (
    [MaterialCode] VARCHAR(50) NOT NULL DEFAULT ,
    [QcInspectionItemCode] VARCHAR(20) NOT NULL DEFAULT ,
    [InspectionType] VARCHAR(10) NULL DEFAULT ,
    [QcSpecDesc] NVARCHAR(MAX) NULL DEFAULT ,
    [InspectionLevel] VARCHAR(20) NULL DEFAULT ,
    [AQL] NUMERIC(10,3) NULL DEFAULT ,
    [SpecValue] NUMERIC(20,5) NULL DEFAULT ,
    [USL] NUMERIC(20,5) NULL DEFAULT ,
    [LSL] NUMERIC(20,5) NULL DEFAULT ,
    [UCL] NUMERIC(20,5) NULL DEFAULT ,
    [LCL] NUMERIC(20,5) NULL DEFAULT ,
    [TextSpecValue] NVARCHAR(200) NULL DEFAULT ,
    [ItemInspectionPrior] INT NULL DEFAULT ,
    [ItemReportPrior] INT NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    [SampleQty] INT NULL DEFAULT ((0)),
    [TempSampleQty] BIGINT NULL DEFAULT ((0)),
    CONSTRAINT [PK_STB_MaterialQcInspectionItem_BendingCutting] PRIMARY KEY CLUSTERED ([MaterialCode], [QcInspectionItemCode])
);
GO

