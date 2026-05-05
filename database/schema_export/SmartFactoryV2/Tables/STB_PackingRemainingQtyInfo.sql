CREATE TABLE [dbo].[STB_PackingRemainingQtyInfo] (
    [PackingRemainingQtyNo] VARCHAR(20) NOT NULL DEFAULT ,
    [CompanyCode] VARCHAR(20) NULL DEFAULT ,
    [WorkCenterCode] VARCHAR(20) NULL DEFAULT ,
    [Barcode] VARCHAR(20) NULL DEFAULT ,
    [RackLocationCode] CHAR(6) NULL DEFAULT ,
    [PackingRemainingQty] NUMERIC(20,5) NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

