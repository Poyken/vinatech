CREATE TABLE [dbo].[STB_SalesPlan] (
    [SalePlanCode] BIGINT IDENTITY(1,1) NOT NULL DEFAULT ,
    [CompanyCode] VARCHAR(20) NULL DEFAULT ,
    [ProductGroupCode] VARCHAR(20) NULL DEFAULT ,
    [ModelCode] VARCHAR(50) NULL DEFAULT ,
    [PlanYearMonth] VARCHAR(7) NULL DEFAULT ,
    [CustomerCode] VARCHAR(20) NULL DEFAULT ,
    [PlanType] VARCHAR(20) NULL DEFAULT ,
    [PlanQty] NUMERIC(20,4) NULL DEFAULT ,
    [PlanBaiscPrice] NUMERIC(20,4) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

