CREATE TABLE [dbo].[STB_WarehouseTemp] (
    [PackingID] VARCHAR(20) NOT NULL DEFAULT ,
    [MaterialCode] VARCHAR(30) NULL DEFAULT ,
    [LotID] VARCHAR(20) NULL DEFAULT ,
    [Qty] NUMERIC(20,5) NULL DEFAULT ,
    [IsCheck] BIT NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [UniqueNumber] BIGINT IDENTITY(1,1) NOT NULL DEFAULT ,
    CONSTRAINT [PK_STB_WarehouseTemp] PRIMARY KEY CLUSTERED ([PackingID], [UniqueNumber])
);
GO

