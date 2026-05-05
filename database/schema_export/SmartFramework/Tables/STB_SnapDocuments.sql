CREATE TABLE [dbo].[STB_SnapDocuments] (
    [DocumentId] VARCHAR(20) NOT NULL DEFAULT ,
    [DocumentName] NVARCHAR(100) NULL DEFAULT ,
    [DocumentDescription] NVARCHAR(MAX) NULL DEFAULT ,
    [ScreenName] VARCHAR(50) NULL DEFAULT ,
    [ViewName] VARCHAR(100) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

