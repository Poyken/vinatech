CREATE TABLE [dbo].[STB_IPCreateHist] (
    [IPCreateHistNo] VARCHAR(20) NOT NULL DEFAULT ,
    [EmployeeNo] VARCHAR(20) NOT NULL DEFAULT ,
    [IPClassCode] VARCHAR(20) NULL DEFAULT ,
    [IPCreateDate] DATE NULL DEFAULT ,
    [IPTitle] NVARCHAR(500) NULL DEFAULT ,
    [ApplicationNo] VARCHAR(30) NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

