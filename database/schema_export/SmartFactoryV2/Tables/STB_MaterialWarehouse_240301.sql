CREATE TABLE [dbo].[STB_MaterialWarehouse_240301] (
    [MaterialWarehouseCode] VARCHAR(20) NOT NULL DEFAULT ,
    [CompanyCode] VARCHAR(20) NULL DEFAULT ,
    [WorkCenterCode] VARCHAR(20) NULL DEFAULT ,
    [MaterialWarehouseName] NVARCHAR(50) NULL DEFAULT ,
    [MaterialWarehouseNameL] NVARCHAR(200) NULL DEFAULT ,
    [MaterialWarehouseDesc] NVARCHAR(200) NULL DEFAULT ,
    [MaterialWarehouseDescL] NVARCHAR(200) NULL DEFAULT ,
    [DefaultLocationCode] VARCHAR(20) NULL DEFAULT ,
    [RequestProductGroupCode] VARCHAR(MAX) NULL DEFAULT ,
    [IsUsed] BIT NULL DEFAULT ,
    [WHExtText01] NVARCHAR(MAX) NULL DEFAULT ,
    [WHExtText02] NVARCHAR(MAX) NULL DEFAULT ,
    [WHExtText03] NVARCHAR(MAX) NULL DEFAULT ,
    [WHExtText04] NVARCHAR(MAX) NULL DEFAULT ,
    [WHExtText05] NVARCHAR(MAX) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    [IsRouteWarehouse] BIT NULL DEFAULT 
);
GO

