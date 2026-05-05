CREATE TABLE [dbo].[STB_ManufacturingCostByRoute] (
    [ApplyDate] DATE NOT NULL DEFAULT ,
    [CompanyCode] VARCHAR(20) NOT NULL DEFAULT ,
    [WorkCenterCode] VARCHAR(20) NOT NULL DEFAULT ,
    [MaterialCode] VARCHAR(20) NOT NULL DEFAULT ,
    [CostTypeCode] VARCHAR(20) NOT NULL DEFAULT ,
    [IsManual] BIT NOT NULL DEFAULT ,
    [RouteCode] VARCHAR(20) NOT NULL DEFAULT ,
    [CostPrice] NUMERIC(20,10) NOT NULL DEFAULT ((0)),
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    [IsUsed] BIT NOT NULL DEFAULT (CONVERT([bit],(1),0)),
    CONSTRAINT [PK_STB_ManufacturingCostByRoute] PRIMARY KEY CLUSTERED ([ApplyDate], [CompanyCode], [WorkCenterCode], [MaterialCode], [CostTypeCode], [IsManual], [RouteCode])
);
GO

