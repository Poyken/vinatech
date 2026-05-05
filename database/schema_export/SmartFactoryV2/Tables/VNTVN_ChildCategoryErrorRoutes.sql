CREATE TABLE [dbo].[VNTVN_ChildCategoryErrorRoutes] (
    [ID] INT IDENTITY(1,1) NOT NULL DEFAULT ,
    [ChildCategoryErrorRouteName] NVARCHAR(MAX) NULL DEFAULT ,
    [ChildCategoryErrorRouteCode] NVARCHAR(MAX) NULL DEFAULT ,
    [Status] BIT NOT NULL DEFAULT (CONVERT([bit],(0),0)),
    [Description] NVARCHAR(MAX) NULL DEFAULT ,
    [CreateDate] DATETIME2 NULL DEFAULT ,
    [UpdateDate] DATETIME2 NULL DEFAULT 
);
GO

