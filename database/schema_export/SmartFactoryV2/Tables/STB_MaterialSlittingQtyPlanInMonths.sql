CREATE TABLE [dbo].[STB_MaterialSlittingQtyPlanInMonths] (
    [ID] INT IDENTITY(1,1) NOT NULL DEFAULT ,
    [MaterialCode] VARCHAR(50) NULL DEFAULT ,
    [Qty] INT NULL DEFAULT ,
    [Yearr] VARCHAR(4) NULL DEFAULT ,
    [Months] VARCHAR(2) NULL DEFAULT ,
    [CreateDatetime] DATETIME NULL DEFAULT 
);
GO

