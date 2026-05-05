CREATE TABLE [dbo].[STB_SparePartBasicLocation] (
    [SPWarehouseCode] VARCHAR(20) NOT NULL DEFAULT ,
    [SparePartCode] VARCHAR(20) NOT NULL DEFAULT ,
    [SPLocationCode] VARCHAR(20) NULL DEFAULT ,
    CONSTRAINT [PK_STB_SparePartBasicLocation] PRIMARY KEY CLUSTERED ([SPWarehouseCode], [SparePartCode])
);
GO

