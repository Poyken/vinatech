CREATE TABLE [dbo].[STB_MachineRepairMaterialHist] (
    [MachineRepairHistoryNo] VARCHAR(20) NOT NULL DEFAULT ,
    [MachineRepairMaterialSeq] VARCHAR(20) NOT NULL DEFAULT ,
    [SparePartChangeHistoryNo] VARCHAR(20) NULL DEFAULT ,
    CONSTRAINT [PK_STB_MachineRepairMaterialHist] PRIMARY KEY CLUSTERED ([MachineRepairHistoryNo], [MachineRepairMaterialSeq])
);
GO

