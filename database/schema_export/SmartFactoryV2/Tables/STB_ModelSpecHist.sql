CREATE TABLE [dbo].[STB_ModelSpecHist] (
    [ModelCode] VARCHAR(50) NOT NULL DEFAULT ,
    [SpecItemCode] VARCHAR(20) NOT NULL DEFAULT ,
    [ChangeMode] VARCHAR(1) NOT NULL DEFAULT ,
    [Seq] BIGINT IDENTITY(1,1) NOT NULL DEFAULT ,
    [SpecValue] NVARCHAR(100) NULL DEFAULT ,
    [UpperSpec] NVARCHAR(100) NULL DEFAULT ,
    [LowerSpec] NVARCHAR(100) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    CONSTRAINT [PK_STB_ModelSpecHist] PRIMARY KEY CLUSTERED ([ModelCode], [SpecItemCode], [ChangeMode], [Seq])
);
GO

