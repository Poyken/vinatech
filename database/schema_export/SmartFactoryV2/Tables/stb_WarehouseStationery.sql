CREATE TABLE [dbo].[stb_WarehouseStationery] (
    [ID] INT IDENTITY(1,1) NOT NULL DEFAULT ,
    [WarehouseCode] NVARCHAR(20) NULL DEFAULT ,
    [WarehouseName] NVARCHAR(50) NULL DEFAULT ,
    [Description] NVARCHAR(200) NULL DEFAULT ,
    [Attribute1] NVARCHAR(50) NULL DEFAULT ,
    [Attribute2] NVARCHAR(50) NULL DEFAULT ,
    [Attribute3] NVARCHAR(50) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] NVARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] NVARCHAR(20) NULL DEFAULT 
);
GO

