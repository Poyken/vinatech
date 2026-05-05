CREATE TABLE [dbo].[STB_SMSCertHist] (
    [ID] BIGINT IDENTITY(1,1) NOT NULL DEFAULT ,
    [UserName] NVARCHAR(30) NOT NULL DEFAULT ,
    [RRN] CHAR(7) NOT NULL DEFAULT ,
    [SMSCertNo] VARCHAR(10) NOT NULL DEFAULT (CONVERT([int],(899999)*rand()+(100000),0)),
    [CertLimitDateTime] DATETIME NOT NULL DEFAULT (dateadd(minute,(5),getdate())),
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate())
);
GO

