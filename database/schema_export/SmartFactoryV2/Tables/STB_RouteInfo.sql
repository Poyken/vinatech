CREATE TABLE [dbo].[STB_RouteInfo] (
    [RouteCode] VARCHAR(20) NOT NULL DEFAULT ,
    [CompanyCode] VARCHAR(20) NULL DEFAULT ,
    [WorkCenterCode] VARCHAR(20) NULL DEFAULT ,
    [RouteType] VARCHAR(20) NULL DEFAULT ,
    [RouteName] NVARCHAR(50) NULL DEFAULT ,
    [IsExternalRoute] BIT NULL DEFAULT ,
    [IsUsed] BIT NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    [IsInterfaceRoute] BIT NULL DEFAULT ,
    [IsRequireMachine] BIT NULL DEFAULT ,
    [StandardTaktTime] NUMERIC(20,5) NULL DEFAULT 
);
GO

