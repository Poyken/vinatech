CREATE TABLE [dbo].[STB_ConsumableInfo] (
    [ConsumableNo] VARCHAR(20) NOT NULL DEFAULT ,
    [Cateogry1] NVARCHAR(100) NULL DEFAULT ,
    [Category2] NVARCHAR(100) NULL DEFAULT ,
    [Category3] NVARCHAR(100) NULL DEFAULT ,
    [MaterialCode] NVARCHAR(100) NULL DEFAULT ,
    [MaterialName] NVARCHAR(100) NULL DEFAULT ,
    [Qty] NUMERIC(20,5) NULL DEFAULT ,
    [Unit] NVARCHAR(10) NULL DEFAULT ,
    [UnitPrice] NUMERIC(20,5) NULL DEFAULT ,
    [ComputedPrice] NUMERIC(38,7) NULL DEFAULT ,
    [ProdDate] DATE NULL DEFAULT ,
    [VendorLotRemark] NVARCHAR(MAX) NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate())
);
GO

