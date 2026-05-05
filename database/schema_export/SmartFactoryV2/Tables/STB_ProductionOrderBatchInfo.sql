CREATE TABLE [dbo].[STB_ProductionOrderBatchInfo] (
    [ParentMaterialCode] VARCHAR(20) NOT NULL DEFAULT ,
    [TargetMaterialCode] VARCHAR(20) NOT NULL DEFAULT ,
    [OrderRate] NUMERIC(20,5) NOT NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NOT NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    CONSTRAINT [PK_STB_ProductionOrderBatchInfo] PRIMARY KEY CLUSTERED ([ParentMaterialCode], [TargetMaterialCode])
);
GO

