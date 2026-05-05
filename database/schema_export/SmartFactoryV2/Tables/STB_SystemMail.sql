CREATE TABLE [dbo].[STB_SystemMail] (
    [SystemMailSeq] BIGINT IDENTITY(1,1) NOT NULL DEFAULT ,
    [TargetMailAddress] VARCHAR(1000) NULL DEFAULT ,
    [MailSubject] NVARCHAR(300) NULL DEFAULT ,
    [MailContents] NVARCHAR(MAX) NULL DEFAULT ,
    [MailSendYn] CHAR(1) NOT NULL DEFAULT ('N'),
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NOT NULL DEFAULT ('admin'),
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

