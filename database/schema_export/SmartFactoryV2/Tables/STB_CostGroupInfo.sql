CREATE TABLE [dbo].[STB_CostGroupInfo] (
    [CostGroupCode] VARCHAR(20) NOT NULL DEFAULT ,
    [CompanyCode] VARCHAR(20) NOT NULL DEFAULT ,
    [WorkCenterCode] VARCHAR(20) NOT NULL DEFAULT ,
    [CostGroupName] VARCHAR(100) NOT NULL DEFAULT ,
    [RouteCode] VARCHAR(20) NULL DEFAULT ,
    [IsUsed] BIT NULL DEFAULT ((1)),
    [CreateDateTime] DATETIME NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    [IsProdWorkerGroup] BIT NULL DEFAULT ,
    [LineCode] VARCHAR(20) NULL DEFAULT 
);
GO

