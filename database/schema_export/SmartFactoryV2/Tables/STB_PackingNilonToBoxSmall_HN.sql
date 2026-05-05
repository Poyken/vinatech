CREATE TABLE [dbo].[STB_PackingNilonToBoxSmall_HN] (
    [PackingNilonToBoxSmallID] VARCHAR(50) NOT NULL DEFAULT ,
    [CurrentQty] INT NULL DEFAULT ,
    [Marking] VARCHAR(100) NULL DEFAULT ,
    [MaterialCode] VARCHAR(50) NULL DEFAULT ,
    [CombineMaterialcodeAndQty] VARCHAR(1000) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(50) NULL DEFAULT ,
    [StatusExport] INT NULL DEFAULT (NULL)
);
GO

