CREATE TABLE [dbo].[STB_SupportRawMaterialSplitHist] (
    [MergeLotID] VARCHAR(50) NOT NULL DEFAULT ,
    [SplitLotID] VARCHAR(50) NOT NULL DEFAULT ,
    [TotalCurrentQty] NUMERIC(20,5) NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    [SplitQty] NUMERIC(20,5) NULL DEFAULT ,
    [IsFixed] BIT NOT NULL DEFAULT (CONVERT([bit],(0),0)),
    CONSTRAINT [PK_STB_SupportRawMaterialSplitHist] PRIMARY KEY CLUSTERED ([MergeLotID], [SplitLotID])
);
GO

