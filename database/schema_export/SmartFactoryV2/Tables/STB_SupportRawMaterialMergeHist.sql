CREATE TABLE [dbo].[STB_SupportRawMaterialMergeHist] (
    [OriginalLotID] VARCHAR(50) NOT NULL DEFAULT ,
    [MergeLotID] VARCHAR(50) NOT NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    CONSTRAINT [PK_STB_SupportRawMaterialMergeHist] PRIMARY KEY CLUSTERED ([OriginalLotID], [MergeLotID])
);
GO

