CREATE TABLE [dbo].[STB_DefectProductionCost] (
    [RouteCode] VARCHAR(20) NULL DEFAULT ,
    [ProductWeight] NUMERIC(20,5) NULL DEFAULT ,
    [ProductCost] NUMERIC(20,5) NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

