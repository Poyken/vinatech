CREATE TABLE [dbo].[STB_BomDetail] (
    [MaterialCode] VARCHAR(50) NOT NULL DEFAULT ,
    [BomVersion] VARCHAR(20) NOT NULL DEFAULT ,
    [ChildMaterialCode] VARCHAR(50) NOT NULL DEFAULT ,
    [ChildBomVersion] VARCHAR(20) NOT NULL DEFAULT ,
    [BomUnit] VARCHAR(10) NULL DEFAULT ,
    [UsedQty] NUMERIC(20,10) NULL DEFAULT ,
    [RouteCode] VARCHAR(20) NULL DEFAULT ,
    [IsOptionItem] BIT NULL DEFAULT ,
    [BomDetailDesc] VARCHAR(200) NULL DEFAULT ,
    [StdCombSec] INT NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    [SortSeq] INT NOT NULL DEFAULT ((0)),
    CONSTRAINT [PK_STB_BomDetail] PRIMARY KEY CLUSTERED ([MaterialCode], [BomVersion], [ChildMaterialCode], [ChildBomVersion])
);
GO

