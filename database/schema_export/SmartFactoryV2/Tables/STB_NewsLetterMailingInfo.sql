CREATE TABLE [dbo].[STB_NewsLetterMailingInfo] (
    [NewsLetterMailingNo] VARCHAR(20) NOT NULL DEFAULT ,
    [CustomerCode] VARCHAR(20) NULL DEFAULT ,
    [PersonName] VARCHAR(100) NULL DEFAULT ,
    [Email] VARCHAR(MAX) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

