CREATE TABLE [dbo].[STB_Vietnam_WasteUnitPrice] (
    [LineCode] VARCHAR(20) NULL DEFAULT ,
    [Volt] NUMERIC(2,1) NULL DEFAULT ,
    [Farad] NUMERIC(5,1) NULL DEFAULT ,
    [SizeCode] VARCHAR(50) NOT NULL DEFAULT ,
    [RouteCode] VARCHAR(20) NOT NULL DEFAULT ,
    [ProcessUnitPriceKG] NUMERIC(30,15) NULL DEFAULT ,
    [ProcessUnitPriceEA] NUMERIC(30,15) NOT NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    [ModelCode] VARCHAR(50) NULL DEFAULT 
);
GO

