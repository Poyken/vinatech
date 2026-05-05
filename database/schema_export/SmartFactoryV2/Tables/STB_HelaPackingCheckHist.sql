CREATE TABLE [dbo].[STB_HelaPackingCheckHist] (
    [LotNo] VARCHAR(20) NOT NULL DEFAULT ,
    [PackageID] VARCHAR(20) NOT NULL DEFAULT ,
    [IsChecked] BIT NULL DEFAULT ,
    [CheckSeqNo] INT NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    CONSTRAINT [PK_STB_HelaPackingCheckHist] PRIMARY KEY CLUSTERED ([LotNo], [PackageID])
);
GO

