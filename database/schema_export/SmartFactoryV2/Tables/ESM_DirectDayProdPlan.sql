CREATE TABLE [dbo].[ESM_DirectDayProdPlan] (
    [DirectDayProdPlanNo] VARCHAR(50) NOT NULL DEFAULT ,
    [DirectDayProdPlanHeadNo] VARCHAR(50) NOT NULL DEFAULT ,
    [DayPlanNo] VARCHAR(20) NOT NULL DEFAULT ,
    [OrgDayPlanNo] VARCHAR(20) NULL DEFAULT ,
    [WorkCenterCode] VARCHAR(20) NOT NULL DEFAULT ,
    [CdCompany] VARCHAR(20) NOT NULL DEFAULT ,
    [MaterialCode] VARCHAR(50) NOT NULL DEFAULT ,
    [LineCode] VARCHAR(20) NULL DEFAULT ,
    [BomVersion] VARCHAR(20) NULL DEFAULT ,
    [ProdQty] NUMERIC(20,4) NULL DEFAULT ,
    [JobDate] DATE NULL DEFAULT ,
    [StuffRouteCode] VARCHAR(300) NULL DEFAULT ,
    [StuffRouteName] VARCHAR(500) NULL DEFAULT ,
    [MaxRouteCode] VARCHAR(20) NULL DEFAULT ,
    [LocationCode] VARCHAR(20) NULL DEFAULT ,
    [MaterialWarehouseCode] VARCHAR(20) NULL DEFAULT 
);
GO

