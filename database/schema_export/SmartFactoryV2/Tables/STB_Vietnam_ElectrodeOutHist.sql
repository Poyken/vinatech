CREATE TABLE [dbo].[STB_Vietnam_ElectrodeOutHist] (
    [Id] INT IDENTITY(1,1) NOT NULL DEFAULT ,
    [LotUniqueNumber] INT NOT NULL DEFAULT ,
    [VCMLine] VARCHAR(50) NOT NULL DEFAULT ,
    [CreateUserId] VARCHAR(50) NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [ChangeUserId] VARCHAR(50) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT 
);
GO

