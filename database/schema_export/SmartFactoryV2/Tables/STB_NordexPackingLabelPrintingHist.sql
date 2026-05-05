CREATE TABLE [dbo].[STB_NordexPackingLabelPrintingHist] (
    [MFGDate] VARCHAR(20) NOT NULL DEFAULT ,
    [Seq] VARCHAR(5) NOT NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NOT NULL DEFAULT ,
    CONSTRAINT [PK_STB_NordexPackingLabelPrintingHist] PRIMARY KEY CLUSTERED ([MFGDate], [Seq])
);
GO

