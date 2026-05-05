CREATE TABLE [dbo].[STB_VNSparePartBasicLocation] (
    [SPWarehouseCode] VARCHAR(20) NOT NULL DEFAULT ,
    [SparePartCode] VARCHAR(20) NOT NULL DEFAULT ,
    [SPLocationCode] VARCHAR(20) NULL DEFAULT ,
    CONSTRAINT [PK_STB_VNSparePartBasicLocation] PRIMARY KEY CLUSTERED ([SPWarehouseCode], [SparePartCode])
);
GO

