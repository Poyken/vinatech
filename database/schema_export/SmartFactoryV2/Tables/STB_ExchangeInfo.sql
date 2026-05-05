CREATE TABLE [dbo].[STB_ExchangeInfo] (
    [Idx] BIGINT IDENTITY(1,1) NOT NULL DEFAULT ,
    [CurrencyCode] VARCHAR(10) NOT NULL DEFAULT ,
    [CurrencyDate] DATE NOT NULL DEFAULT ,
    [ExchangeRateAmount] NUMERIC(10,5) NOT NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate())
);
GO

