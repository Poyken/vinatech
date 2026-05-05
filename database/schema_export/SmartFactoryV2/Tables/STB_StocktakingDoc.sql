CREATE TABLE [dbo].[STB_StocktakingDoc] (
    [StocktakingDocNo] VARCHAR(20) NOT NULL DEFAULT ,
    [CompanyCode] VARCHAR(20) NULL DEFAULT ,
    [WorkCenterCode] VARCHAR(20) NULL DEFAULT ,
    [MaterialWarehouseCode] VARCHAR(20) NULL DEFAULT ,
    [MaterialCode] VARCHAR(50) NULL DEFAULT ,
    [BasicDate] DATE NULL DEFAULT ,
    [StocktakingDesc] NVARCHAR(200) NULL DEFAULT ,
    [IsFinish] BIT NULL DEFAULT ,
    [GIDocNo] VARCHAR(20) NULL DEFAULT ,
    [GRDocNo] VARCHAR(20) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    [MLExtText01] NVARCHAR(MAX) NULL DEFAULT 
);
GO

