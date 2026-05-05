CREATE TABLE [dbo].[STB_MoldLocation] (
    [MoldLocationCode] VARCHAR(20) NOT NULL DEFAULT ,
    [CompanyCode] VARCHAR(20) NULL DEFAULT ,
    [WorkCenterCode] VARCHAR(20) NULL DEFAULT ,
    [LocationName] NVARCHAR(100) NULL DEFAULT ,
    [LocationDesc1] NVARCHAR(200) NULL DEFAULT ,
    [LocationDesc2] NVARCHAR(200) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

