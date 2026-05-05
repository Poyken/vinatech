CREATE TABLE [dbo].[STB_GembaworkMemo] (
    [GembaworkMemoNo] VARCHAR(20) NOT NULL DEFAULT ,
    [AuthorName] NVARCHAR(20) NOT NULL DEFAULT ,
    [MemoContent] NVARCHAR(MAX) NULL DEFAULT ,
    [RelatedPicture1] VARCHAR(MAX) NULL DEFAULT ,
    [RelatedPicture2] VARCHAR(MAX) NULL DEFAULT ,
    [RelatedPicture3] VARCHAR(MAX) NULL DEFAULT ,
    [RelatedPicture4] VARCHAR(MAX) NULL DEFAULT ,
    [RelatedPicture5] VARCHAR(MAX) NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NOT NULL DEFAULT ('Gembawork'),
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

