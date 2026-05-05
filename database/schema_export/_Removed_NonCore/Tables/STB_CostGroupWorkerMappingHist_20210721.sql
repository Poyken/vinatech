CREATE TABLE [dbo].[STB_CostGroupWorkerMappingHist_20210721] (
    [JobDate] DATE NOT NULL DEFAULT ,
    [CostGroupCode] VARCHAR(20) NOT NULL DEFAULT ,
    [CostGroupSeq] INT NOT NULL DEFAULT ,
    [WorkerCode] VARCHAR(20) NOT NULL DEFAULT ,
    [IsAssigned] BIT NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    [JobStartDateTime] DATETIME NULL DEFAULT ,
    [JobEndDateTime] DATETIME NULL DEFAULT ,
    [BasicWorkTime] NUMERIC(5,1) NULL DEFAULT ,
    [SupportCostGroupCode] VARCHAR(20) NULL DEFAULT ,
    [ApplyTime] NUMERIC(20,1) NULL DEFAULT ,
    [WorkTypeCode] VARCHAR(20) NULL DEFAULT ,
    [CostGroupRemark] NVARCHAR(MAX) NULL DEFAULT 
);
GO

