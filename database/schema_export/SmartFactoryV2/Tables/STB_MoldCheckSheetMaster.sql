CREATE TABLE [dbo].[STB_MoldCheckSheetMaster] (
    [MoldCheckSheetCode] VARCHAR(20) NOT NULL DEFAULT ,
    [MoldCheckTypeCode] VARCHAR(20) NULL DEFAULT ,
    [MoldCheckSheetName] NVARCHAR(100) NULL DEFAULT ,
    [MoldImage] VARBINARY(MAX) NULL DEFAULT ,
    [CheckDesc] NVARCHAR(MAX) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

