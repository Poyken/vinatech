CREATE TABLE [dbo].[STB_StationeryInfo] (
    [ID] INT IDENTITY(1,1) NOT NULL DEFAULT ,
    [StationeryCode] NVARCHAR(50) NULL DEFAULT ,
    [StationeryName] NVARCHAR(200) NULL DEFAULT ,
    [Description] NVARCHAR(500) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] NVARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] NVARCHAR(20) NULL DEFAULT ,
    [BasicUnit] NVARCHAR(20) NULL DEFAULT ,
    [TypeStationery] NVARCHAR(50) NULL DEFAULT ,
    [CompanyCode] NVARCHAR(50) NULL DEFAULT ,
    [WorkCenterCode] NVARCHAR(50) NULL DEFAULT ,
    [NameWorkCenterCode] NVARCHAR(50) NULL DEFAULT 
);
GO

