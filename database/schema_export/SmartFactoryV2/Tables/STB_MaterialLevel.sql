CREATE TABLE [dbo].[STB_MaterialLevel] (
    [MaterialCode] NVARCHAR(50) NOT NULL DEFAULT ,
    [MaterialName] NVARCHAR(100) NULL DEFAULT ,
    [MaterialLevel] INT NULL DEFAULT ,
    [Quantity] FLOAT NULL DEFAULT ,
    [ParentID] NVARCHAR(50) NOT NULL DEFAULT ,
    CONSTRAINT [PK_STB_MaterialLevel] PRIMARY KEY CLUSTERED ([MaterialCode], [ParentID])
);
GO

