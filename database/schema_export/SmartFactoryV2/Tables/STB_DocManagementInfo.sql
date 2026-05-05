CREATE TABLE [dbo].[STB_DocManagementInfo] (
    [DocManagementCode] VARCHAR(20) NOT NULL DEFAULT ,
    [FactoryCode] VARCHAR(10) NOT NULL DEFAULT ,
    [ProcessCode] VARCHAR(10) NOT NULL DEFAULT ,
    [ProductCode] VARCHAR(10) NOT NULL DEFAULT ,
    [ContentsCode] VARCHAR(10) NOT NULL DEFAULT ,
    [DocFileName] VARCHAR(400) NULL DEFAULT ,
    [DocSummaryContents] NVARCHAR(4000) NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    [DocCreateWorkerCode] VARCHAR(20) NULL DEFAULT 
);
GO

