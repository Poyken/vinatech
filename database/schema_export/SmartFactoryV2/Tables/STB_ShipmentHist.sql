CREATE TABLE [dbo].[STB_ShipmentHist] (
    [ShipmentHistNo] VARCHAR(20) NOT NULL DEFAULT ,
    [ShippmentAreaCode] VARCHAR(20) NULL DEFAULT ,
    [ShipmentDate] DATE NULL DEFAULT ,
    [ShippingDate] DATE NULL DEFAULT ,
    [NationCode] VARCHAR(20) NULL DEFAULT ,
    [CustomerCode] VARCHAR(20) NULL DEFAULT ,
    [SalesTypeCode] VARCHAR(20) NULL DEFAULT ,
    [ShipmentQty] NUMERIC(20,5) NULL DEFAULT ,
    [GIUnitPrice] NUMERIC(20,5) NULL DEFAULT ,
    [FCSalesPrice] NUMERIC(38,7) NULL DEFAULT ,
    [ExchangeRate] NUMERIC(20,5) NULL DEFAULT ,
    [SalesPrice] NUMERIC(38,6) NULL DEFAULT ,
    [TransportTypeCode] VARCHAR(20) NULL DEFAULT ,
    [ShippingCompanyName] NVARCHAR(100) NULL DEFAULT ,
    [AirWayBillNo] VARCHAR(100) NULL DEFAULT ,
    [MaterialCode] VARCHAR(20) NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

