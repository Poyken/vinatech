CREATE TABLE [dbo].[STB_ProdInspIndivisualSpec] (
    [MaterialCode] VARCHAR(20) NOT NULL DEFAULT ,
    [QcInspectionItemCode] VARCHAR(20) NOT NULL DEFAULT ,
    [SpecValue] NUMERIC(20,5) NULL DEFAULT ,
    [USL] NUMERIC(20,5) NULL DEFAULT ,
    [LSL] NUMERIC(20,5) NULL DEFAULT ,
    CONSTRAINT [PK_STB_ProdInspIndivisualSpec] PRIMARY KEY CLUSTERED ([MaterialCode], [QcInspectionItemCode])
);
GO

