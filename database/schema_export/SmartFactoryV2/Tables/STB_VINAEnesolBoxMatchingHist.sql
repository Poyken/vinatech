CREATE TABLE [dbo].[STB_VINAEnesolBoxMatchingHist] (
    [LargeBoxLabelPrintHistNo] VARCHAR(20) NOT NULL DEFAULT ,
    [SmallBoxLabelPrintHistNo] VARCHAR(20) NOT NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NOT NULL DEFAULT ,
    CONSTRAINT [PK_STB_VINAEnesolBoxMatchingHist] PRIMARY KEY CLUSTERED ([LargeBoxLabelPrintHistNo], [SmallBoxLabelPrintHistNo])
);
GO

