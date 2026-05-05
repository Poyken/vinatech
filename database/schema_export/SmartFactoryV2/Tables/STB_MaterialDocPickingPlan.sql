CREATE TABLE [dbo].[STB_MaterialDocPickingPlan] (
    [MaterialDocDetailNo] VARCHAR(20) NOT NULL DEFAULT ,
    [PickingPlanSeq] INT NOT NULL DEFAULT ,
    [MaterialStockNo] BIGINT NOT NULL DEFAULT ,
    [GRDate] VARCHAR(10) NOT NULL DEFAULT ,
    [PickingAssingQty] NUMERIC(20,5) NULL DEFAULT ,
    [PickingQty] NUMERIC(20,5) NULL DEFAULT ,
    [MaterialDocNo] VARCHAR(20) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    CONSTRAINT [PK_STB_MaterialDocPickingPlan] PRIMARY KEY CLUSTERED ([MaterialDocDetailNo], [PickingPlanSeq])
);
GO

