CREATE TABLE [dbo].[STB_MaterialStockAttributeInfo] (
    [MaterialCode] VARCHAR(50) NOT NULL DEFAULT ,
    [IsUseBarcode] BIT NULL DEFAULT ,
    [IsLotUse] BIT NULL DEFAULT ,
    [IsVendorLotUse] BIT NULL DEFAULT ,
    [IsUseVendorBarcode] BIT NULL DEFAULT ,
    [IsLifetimeUse] BIT NULL DEFAULT ,
    [IsFIFO] BIT NULL DEFAULT ,
    [SaftyStock] NUMERIC(20,5) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

