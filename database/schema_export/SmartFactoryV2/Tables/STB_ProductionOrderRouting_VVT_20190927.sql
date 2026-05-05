CREATE TABLE [dbo].[STB_ProductionOrderRouting_VVT_20190927] (
    [PoRoutingSeqNo] BIGINT IDENTITY(1,1) NOT NULL DEFAULT ,
    [PONo] VARCHAR(20) NULL DEFAULT ,
    [RouteCode] VARCHAR(20) NULL DEFAULT ,
    [RouteIndex] INT NULL DEFAULT ,
    [IsInputRoute] BIT NULL DEFAULT ,
    [IsOutputRoute] BIT NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

