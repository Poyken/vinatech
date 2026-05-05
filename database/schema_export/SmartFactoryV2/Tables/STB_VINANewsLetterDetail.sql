CREATE TABLE [dbo].[STB_VINANewsLetterDetail] (
    [NewsLetterDetailNo] VARCHAR(20) NOT NULL DEFAULT ,
    [NewsLetterNo] VARCHAR(10) NOT NULL DEFAULT ,
    [Title] VARCHAR(200) NULL DEFAULT ,
    [TitleAlign] VARCHAR(10) NULL DEFAULT ('c15'),
    [ImagePath] VARCHAR(500) NULL DEFAULT ,
    [ImageAlign] VARCHAR(10) NULL DEFAULT ('c25'),
    [ImageText] VARCHAR(500) NULL DEFAULT ,
    [ImageTextAlign] VARCHAR(10) NULL DEFAULT ('c25'),
    [Text] VARCHAR(MAX) NULL DEFAULT ,
    [TextAlign] VARCHAR(10) NULL DEFAULT ('c15'),
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    [ImageWidth] INT NULL DEFAULT 
);
GO

