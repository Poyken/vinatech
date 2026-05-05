CREATE TABLE [dbo].[STB_BomBatchInfo] (
    [MaterialCode] VARCHAR(50) NOT NULL DEFAULT ,
    [BomVersion] VARCHAR(20) NOT NULL DEFAULT ,
    [ChildMaterialCode] VARCHAR(50) NOT NULL DEFAULT ,
    [ChildBomVersion] VARCHAR(20) NOT NULL DEFAULT ,
    [BomUnit] VARCHAR(10) NULL DEFAULT ,
    [ChildBomUnit] VARCHAR(10) NULL DEFAULT ,
    [UsedQty] NUMERIC(20,5) NULL DEFAULT ,
    [RouteCode] VARCHAR(20) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    CONSTRAINT [PK_STB_BomBatchInfo] PRIMARY KEY CLUSTERED ([MaterialCode], [BomVersion], [ChildMaterialCode], [ChildBomVersion])
);
GO

