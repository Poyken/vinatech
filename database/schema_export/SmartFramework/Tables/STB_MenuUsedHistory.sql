CREATE TABLE [dbo].[STB_MenuUsedHistory] (
    [UseDate] DATE NOT NULL DEFAULT ,
    [UserID] VARCHAR(20) NOT NULL DEFAULT ,
    [Name] VARCHAR(50) NOT NULL DEFAULT ,
    [UsedCount] INT NULL DEFAULT ,
    CONSTRAINT [PK_STB_MenuUsedHistory] PRIMARY KEY CLUSTERED ([UseDate], [UserID], [Name])
);
GO

