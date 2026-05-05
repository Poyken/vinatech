CREATE TABLE [dbo].[STB_BasicRoutingDetail] (
    [BasicRoutingDetailNo] VARCHAR(20) NOT NULL DEFAULT ,
    [BasicRoutingCode] VARCHAR(20) NULL DEFAULT ,
    [RouteCode] VARCHAR(20) NULL DEFAULT ,
    [RouteIndex] INT NULL DEFAULT ,
    [IsInputRoute] BIT NULL DEFAULT ,
    [IsOutputRoute] BIT NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    [CompanyCode] VARCHAR(20) NULL DEFAULT ,
    [WorkCenterCode] VARCHAR(20) NULL DEFAULT 
);
GO

