CREATE TABLE [dbo].[STB_LineNonOperationInfo] (
    [LineNonOperationCode] VARCHAR(20) NOT NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    [CompanyCode] VARCHAR(20) NOT NULL DEFAULT ,
    [WorkCenterCode] VARCHAR(20) NOT NULL DEFAULT ,
    [LineNonOperationName] NVARCHAR(MAX) NULL DEFAULT ,
    CONSTRAINT [PK_STB_LineNonOperationInfo] PRIMARY KEY CLUSTERED ([CompanyCode], [WorkCenterCode], [LineNonOperationCode])
);
GO

