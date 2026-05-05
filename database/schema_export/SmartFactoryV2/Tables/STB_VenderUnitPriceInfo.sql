CREATE TABLE [dbo].[STB_VenderUnitPriceInfo] (
    [Idx] BIGINT IDENTITY(1,1) NOT NULL DEFAULT ,
    [MaterialCode] VARCHAR(20) NOT NULL DEFAULT ,
    [ChangeDate] DATE NOT NULL DEFAULT ,
    [CurrencyCode] VARCHAR(10) NOT NULL DEFAULT ,
    [UnitPrice] NUMERIC(20,6) NOT NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [CustomerCode] VARCHAR(20) NULL DEFAULT 
);
GO

