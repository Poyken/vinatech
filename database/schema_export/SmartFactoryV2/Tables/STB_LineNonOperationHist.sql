CREATE TABLE [dbo].[STB_LineNonOperationHist] (
    [LineNonOperationHistNo] VARCHAR(20) NOT NULL DEFAULT ,
    [CompanyCode] VARCHAR(20) NULL DEFAULT ,
    [WorkCenterCode] VARCHAR(20) NULL DEFAULT ,
    [LineCode] VARCHAR(20) NULL DEFAULT ,
    [LineStopDateTime] DATETIME NULL DEFAULT ,
    [LineRestartDateTime] DATETIME NULL DEFAULT ,
    [LineStopRemark] NVARCHAR(MAX) NULL DEFAULT ,
    [LineRestartRemark] NVARCHAR(MAX) NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    [LineNonOperationCode] VARCHAR(20) NULL DEFAULT ,
    [DashboardRouteCode] VARCHAR(20) NULL DEFAULT 
);
GO

