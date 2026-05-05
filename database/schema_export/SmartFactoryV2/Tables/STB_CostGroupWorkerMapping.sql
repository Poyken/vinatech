CREATE TABLE [dbo].[STB_CostGroupWorkerMapping] (
    [CostGroupCode] VARCHAR(20) NOT NULL DEFAULT ,
    [WorkerCode] VARCHAR(20) NOT NULL DEFAULT ,
    [IsAssigned] BIT NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    [Seq] INT NOT NULL DEFAULT ((1)),
    [SupportCostGroupCode] VARCHAR(20) NULL DEFAULT ,
    [ApplyTime] NUMERIC(20,1) NULL DEFAULT ,
    [WorkTypeCode] VARCHAR(20) NULL DEFAULT ('01'),
    [CostGroupRemark] NVARCHAR(MAX) NULL DEFAULT ,
    CONSTRAINT [PK_STB_CostGroupWorkerMapping] PRIMARY KEY CLUSTERED ([CostGroupCode], [WorkerCode], [Seq])
);
GO

