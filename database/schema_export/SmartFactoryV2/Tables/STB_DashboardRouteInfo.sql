CREATE TABLE [dbo].[STB_DashboardRouteInfo] (
    [CompanyCode] VARCHAR(20) NOT NULL DEFAULT ,
    [WorkCenterCode] VARCHAR(20) NOT NULL DEFAULT ,
    [DashboardRouteCode] VARCHAR(20) NOT NULL DEFAULT ,
    [DashboardRouteName] NVARCHAR(100) NOT NULL DEFAULT ,
    [ProdRouteTypeCode] VARCHAR(20) NOT NULL DEFAULT ,
    [Remark] NVARCHAR(MAX) NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    CONSTRAINT [PK_STB_DashboardRouteInfo] PRIMARY KEY CLUSTERED ([CompanyCode], [WorkCenterCode], [DashboardRouteCode])
);
GO

