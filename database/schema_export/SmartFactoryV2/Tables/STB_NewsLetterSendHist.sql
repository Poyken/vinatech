CREATE TABLE [dbo].[STB_NewsLetterSendHist] (
    [NewsLetterSendHistNo] VARCHAR(20) NOT NULL DEFAULT ,
    [NewsLetterMailingNo] VARCHAR(20) NOT NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    [NewsLetterNo] VARCHAR(20) NULL DEFAULT ,
    [NewsLetterSource] VARCHAR(MAX) NULL DEFAULT 
);
GO

