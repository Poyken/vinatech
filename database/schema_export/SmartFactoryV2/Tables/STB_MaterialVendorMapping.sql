CREATE TABLE [dbo].[STB_MaterialVendorMapping] (
    [MaterialCode] VARCHAR(50) NOT NULL DEFAULT ,
    [CustomerCode] VARCHAR(20) NOT NULL DEFAULT ,
    [InspectionType] VARCHAR(20) NULL DEFAULT ,
    [InspectionLevel] VARCHAR(20) NULL DEFAULT ,
    [AQL] VARCHAR(10) NULL DEFAULT ,
    [UnitPriceQty] NUMERIC(20,5) NULL DEFAULT ,
    [UnitPrice] NUMERIC(20,5) NULL DEFAULT ,
    [BasicDeliveryDay] INT NULL DEFAULT ,
    [MVMExtText01] VARCHAR(50) NULL DEFAULT ,
    [MVMExtText02] VARCHAR(50) NULL DEFAULT ,
    [MVMExtText03] VARCHAR(50) NULL DEFAULT ,
    [MVMExtText04] VARCHAR(50) NULL DEFAULT ,
    [MVMExtText05] VARCHAR(50) NULL DEFAULT ,
    [IsUsed] BIT NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    CONSTRAINT [PK_STB_MaterialVendorMapping] PRIMARY KEY CLUSTERED ([MaterialCode], [CustomerCode])
);
GO

