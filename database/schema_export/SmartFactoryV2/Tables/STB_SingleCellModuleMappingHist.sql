CREATE TABLE [dbo].[STB_SingleCellModuleMappingHist] (
    [ModuleLotNo] VARCHAR(20) NOT NULL DEFAULT ,
    [Seq] INT NOT NULL DEFAULT ,
    [SingleCellLotNo] VARCHAR(20) NOT NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    CONSTRAINT [PK_STB_SingleCellModuleMappingHist] PRIMARY KEY CLUSTERED ([ModuleLotNo], [Seq], [SingleCellLotNo])
);
GO

