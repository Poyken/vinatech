CREATE TABLE [dbo].[STB_SparePartIOHistory] (
    [SparePartIOHistoryNo] VARCHAR(20) NOT NULL DEFAULT ,
    [CompanyCode] VARCHAR(20) NULL DEFAULT ,
    [WorkCenterCode] VARCHAR(20) NULL DEFAULT ,
    [SPWarehouseCode] VARCHAR(20) NULL DEFAULT ,
    [SPLocationCode] VARCHAR(20) NULL DEFAULT ,
    [SparePartIOTypeCode] VARCHAR(20) NULL DEFAULT ,
    [SparePartCode] VARCHAR(20) NULL DEFAULT ,
    [VendorCode] VARCHAR(20) NULL DEFAULT ,
    [UnitPrice] NUMERIC(20,5) NULL DEFAULT ,
    [ProcessQty] NUMERIC(20,5) NULL DEFAULT ,
    [HistoryText] NVARCHAR(100) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    [CurlingGomaUniqueNo] VARCHAR(20) NULL DEFAULT ,
    [LineCode] VARCHAR(20) NULL DEFAULT ,
    [GRDate] DATE NULL DEFAULT ,
    [GIDate] DATE NULL DEFAULT ,
    [IssueExecWorkerCode] VARCHAR(20) NULL DEFAULT 
);
GO

