CREATE TABLE [dbo].[STB_ManufacturingCostAvgByRoute] (
    [ApplyDate] DATE NOT NULL DEFAULT ,
    [CompanyCode] VARCHAR(20) NOT NULL DEFAULT ,
    [WorkCenterCode] VARCHAR(20) NOT NULL DEFAULT ,
    [MaterialCode] VARCHAR(20) NOT NULL DEFAULT ,
    [CostTypeCode] VARCHAR(20) NOT NULL DEFAULT ,
    [IsManual] BIT NOT NULL DEFAULT ,
    [RouteCode] VARCHAR(20) NOT NULL DEFAULT ,
    [CostPrice] NUMERIC(20,10) NOT NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

