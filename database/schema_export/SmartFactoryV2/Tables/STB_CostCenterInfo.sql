CREATE TABLE [dbo].[STB_CostCenterInfo] (
    [CompanyCode] VARCHAR(20) NOT NULL DEFAULT ,
    [WorkCenterCode] VARCHAR(20) NOT NULL DEFAULT ,
    [CostCenterCode] VARCHAR(20) NOT NULL DEFAULT ,
    [CostCenterName] NVARCHAR(100) NULL DEFAULT ,
    [IsUsed] BIT NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    CONSTRAINT [PK_STB_CostCenterInfo] PRIMARY KEY CLUSTERED ([CompanyCode], [WorkCenterCode], [CostCenterCode])
);
GO

