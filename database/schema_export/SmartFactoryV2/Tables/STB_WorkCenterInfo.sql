CREATE TABLE [dbo].[STB_WorkCenterInfo] (
    [WorkCenterCode] VARCHAR(20) NOT NULL DEFAULT ,
    [WorkCenterName] NVARCHAR(50) NULL DEFAULT ,
    [WorkCenterNameL] NVARCHAR(50) NULL DEFAULT ,
    [CompanyCode] VARCHAR(20) NULL DEFAULT ,
    [WorkCenterDesc] NVARCHAR(200) NULL DEFAULT ,
    [WorkCenterDescL] NVARCHAR(200) NULL DEFAULT ,
    [WorkCenterBarcode] VARCHAR(10) NULL DEFAULT ,
    [IsUsed] BIT NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    [WorkCenterGroup] VARCHAR(20) NULL DEFAULT 
);
GO

