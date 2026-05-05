CREATE TABLE [dbo].[STB_ProductionOrderRouting] (
    [PoRoutingSeqNo] BIGINT IDENTITY(1,1) NOT NULL DEFAULT ,
    [PONo] VARCHAR(20) NULL DEFAULT ,
    [RouteCode] VARCHAR(20) NULL DEFAULT ,
    [RouteIndex] INT NULL DEFAULT ,
    [IsInputRoute] BIT NULL DEFAULT ,
    [IsOutputRoute] BIT NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    [CompanyCode] VARCHAR(3) NOT NULL DEFAULT 
);
GO

