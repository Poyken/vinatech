CREATE TABLE [dbo].[STB_InterimProdQtyInfo] (
    [InterimProdQtyInfoNo] BIGINT IDENTITY(1,1) NOT NULL DEFAULT ,
    [ControlNo] VARCHAR(20) NOT NULL DEFAULT ,
    [RouteCode] VARCHAR(20) NOT NULL DEFAULT ,
    [ProdQty] NUMERIC(20,2) NOT NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

