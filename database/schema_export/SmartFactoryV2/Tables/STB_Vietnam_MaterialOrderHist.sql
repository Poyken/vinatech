CREATE TABLE [dbo].[STB_Vietnam_MaterialOrderHist] (
    [Id] INT IDENTITY(1,1) NOT NULL DEFAULT ,
    [LineCode] VARCHAR(30) NULL DEFAULT ,
    [DayPlanNo] VARCHAR(30) NULL DEFAULT ,
    [MaterialCode] VARCHAR(30) NULL DEFAULT ,
    [LotID] VARCHAR(20) NULL DEFAULT ,
    [Qty] FLOAT NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT (getdate()),
    [CreateUserId] VARCHAR(30) NULL DEFAULT ,
    [Comment] NVARCHAR(200) NULL DEFAULT ,
    [OrderDate] DATETIME NULL DEFAULT ,
    [ProductCode] VARCHAR(30) NULL DEFAULT 
);
GO

