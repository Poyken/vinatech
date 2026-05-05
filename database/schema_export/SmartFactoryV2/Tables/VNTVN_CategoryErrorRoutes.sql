CREATE TABLE [dbo].[VNTVN_CategoryErrorRoutes] (
    [ID] INT IDENTITY(1,1) NOT NULL DEFAULT ,
    [CategoryErrorRouteName] NVARCHAR(MAX) NULL DEFAULT ,
    [CategoryErrorRouteCode] NVARCHAR(MAX) NULL DEFAULT ,
    [CompanyCode] NVARCHAR(MAX) NULL DEFAULT ,
    [Description] NVARCHAR(MAX) NULL DEFAULT ,
    [Status] BIT NOT NULL DEFAULT (CONVERT([bit],(0),0)),
    [CreateDate] DATETIME2 NULL DEFAULT ,
    [UpdateDate] DATETIME2 NULL DEFAULT ,
    [RouteCode] NVARCHAR(MAX) NULL DEFAULT 
);
GO

