CREATE TABLE [dbo].[STB_AggregationPeriod] (
    [BaseMonth] VARCHAR(7) NOT NULL DEFAULT ,
    [FromDate] DATE NULL DEFAULT ,
    [ToDate] DATE NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NOT NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

