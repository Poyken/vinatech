CREATE TABLE [dbo].[Stb_vietnam_barcodeWeight] (
    [Barcode] VARCHAR(30) NOT NULL DEFAULT ,
    [Weight] FLOAT NOT NULL DEFAULT ,
    [UnitW] FLOAT NULL DEFAULT ,
    [PCS] FLOAT NULL DEFAULT ,
    [OddQty] FLOAT NULL DEFAULT ,
    [Remark] NVARCHAR(1000) NULL DEFAULT ,
    [CreateUserID] VARCHAR(30) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT (getdate()),
    [OddQtyTotal] VARCHAR(20) NULL DEFAULT 
);
GO

