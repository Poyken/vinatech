CREATE TABLE [dbo].[STB_BaseCode] (
    [CodeGroup] VARCHAR(50) NOT NULL DEFAULT ,
    [ItemCode] VARCHAR(50) NOT NULL DEFAULT ,
    [Description] NVARCHAR(MAX) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [DisplayIndex] INT NULL DEFAULT ,
    [Remark] NVARCHAR(500) NULL DEFAULT ,
    CONSTRAINT [PK_STB_BaseCode] PRIMARY KEY CLUSTERED ([CodeGroup], [ItemCode])
);
GO

