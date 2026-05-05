CREATE TABLE [dbo].[STB_VINANewsLetterMaster] (
    [NewsLetterNo] VARCHAR(10) NOT NULL DEFAULT ,
    [Header] VARCHAR(MAX) NULL DEFAULT ,
    [Footer] VARCHAR(MAX) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    [OriginalArticleLinkUrl] VARCHAR(500) NULL DEFAULT ,
    [Contents] VARCHAR(MAX) NULL DEFAULT ,
    [PublishNo] VARCHAR(10) NOT NULL DEFAULT (right('000'+CONVERT([varchar](10),CONVERT([int],CONVERT([varchar](6),getdate(),(112)),0)-(201903),0),(4)))
);
GO

