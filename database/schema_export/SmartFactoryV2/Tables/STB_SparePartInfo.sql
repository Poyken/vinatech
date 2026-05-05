CREATE TABLE [dbo].[STB_SparePartInfo] (
    [SparePartCode] VARCHAR(20) NOT NULL DEFAULT ,
    [SparePartName] NVARCHAR(100) NULL DEFAULT ,
    [SparePartSpec01] NVARCHAR(100) NULL DEFAULT ,
    [SparePartSpec02] NVARCHAR(100) NULL DEFAULT ,
    [SparePartSpec03] NVARCHAR(100) NULL DEFAULT ,
    [SparePartSpec04] NVARCHAR(100) NULL DEFAULT ,
    [SparePartSpec05] NVARCHAR(100) NULL DEFAULT ,
    [SparePartImage] BIGINT NULL DEFAULT ,
    [BasicUnitPrice] NUMERIC(15,2) NULL DEFAULT ,
    [BasicDeliveryDay] INT NULL DEFAULT ,
    [BasicUnit] VARCHAR(20) NULL DEFAULT ,
    [SafeQty] NUMERIC(20,5) NULL DEFAULT ,
    [LastDeliveryVendor] VARCHAR(20) NULL DEFAULT ,
    [CompatibilityGroup] NVARCHAR(50) NULL DEFAULT ,
    [IsUsed] BIT NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    [MinimumOrderQty] NUMERIC(20,5) NULL DEFAULT ,
    [SPWarehouseCode] VARCHAR(30) NULL DEFAULT ,
    [SPLocationCode] VARCHAR(30) NULL DEFAULT 
);
GO

