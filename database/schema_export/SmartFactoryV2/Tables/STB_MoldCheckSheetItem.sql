CREATE TABLE [dbo].[STB_MoldCheckSheetItem] (
    [MoldCheckSheetCode] VARCHAR(20) NOT NULL DEFAULT ,
    [ItemNo] INT NOT NULL DEFAULT ,
    [DisplayIndex] INT NULL DEFAULT ,
    [CheckPointNo] VARCHAR(10) NULL DEFAULT ,
    [CheckPointText] NVARCHAR(100) NULL DEFAULT ,
    [CheckSubNo] VARCHAR(10) NULL DEFAULT ,
    [CheckItem] NVARCHAR(200) NULL DEFAULT ,
    [CheckText] NVARCHAR(MAX) NULL DEFAULT ,
    [CheckDesc] NVARCHAR(MAX) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    CONSTRAINT [PK_STB_MoldCheckSheetItem] PRIMARY KEY CLUSTERED ([MoldCheckSheetCode], [ItemNo])
);
GO

