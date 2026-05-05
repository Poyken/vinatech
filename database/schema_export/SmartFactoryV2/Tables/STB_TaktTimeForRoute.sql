CREATE TABLE [dbo].[STB_TaktTimeForRoute] (
    [CompanyCode] VARCHAR(20) NOT NULL DEFAULT ,
    [WorkCenterCode] VARCHAR(20) NOT NULL DEFAULT ,
    [Barcode] VARCHAR(20) NOT NULL DEFAULT ,
    [RouteCode] VARCHAR(20) NOT NULL DEFAULT ,
    [ProdQty] BIGINT NULL DEFAULT ,
    [ProdDateTime] DATETIME NULL DEFAULT ,
    [StandardTaktTime] NUMERIC(20,5) NULL DEFAULT ,
    [TotStandardTaktTime] NUMERIC(38,5) NULL DEFAULT ,
    [TotActualTaktTime] NUMERIC(20,5) NULL DEFAULT ,
    [Remark] NVARCHAR(MAX) NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NOT NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    CONSTRAINT [PK_STB_TaktTimeForRoute] PRIMARY KEY CLUSTERED ([CompanyCode], [WorkCenterCode], [Barcode], [RouteCode])
);
GO

