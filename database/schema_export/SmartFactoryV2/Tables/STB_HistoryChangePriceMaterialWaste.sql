CREATE TABLE [dbo].[STB_HistoryChangePriceMaterialWaste] (
    [ID] INT IDENTITY(1,1) NOT NULL DEFAULT ,
    [Materialcode] NVARCHAR(50) NULL DEFAULT ,
    [PRICES] VARCHAR(50) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(50) NULL DEFAULT 
);
GO

