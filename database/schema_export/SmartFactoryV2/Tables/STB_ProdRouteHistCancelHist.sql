CREATE TABLE [dbo].[STB_ProdRouteHistCancelHist] (
    [Idx] BIGINT IDENTITY(1,1) NOT NULL DEFAULT ,
    [LotNo] VARCHAR(20) NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NOT NULL DEFAULT 
);
GO

