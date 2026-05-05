CREATE TABLE [dbo].[STB_WasteUnitPrice] (
    [LineCode] VARCHAR(20) NOT NULL DEFAULT ,
    [Volt] NUMERIC(2,1) NOT NULL DEFAULT ,
    [Farad] NUMERIC(5,1) NOT NULL DEFAULT ,
    [Size] VARCHAR(10) NOT NULL DEFAULT ,
    [RouteCode] VARCHAR(20) NOT NULL DEFAULT ,
    [ProcessUnitPriceKG] NUMERIC(10,2) NOT NULL DEFAULT ,
    [ProcessUnitPriceEA] NUMERIC(10,2) NOT NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    CONSTRAINT [PK_STB_WasteUnitPrice] PRIMARY KEY CLUSTERED ([LineCode], [Volt], [Farad], [Size], [RouteCode])
);
GO

