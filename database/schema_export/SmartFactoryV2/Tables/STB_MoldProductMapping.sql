CREATE TABLE [dbo].[STB_MoldProductMapping] (
    [MoldNumber] VARCHAR(50) NOT NULL DEFAULT ,
    [MaterialCode] VARCHAR(50) NOT NULL DEFAULT ,
    [Cabity] INT NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    CONSTRAINT [PK_STB_MoldProductMapping] PRIMARY KEY CLUSTERED ([MoldNumber], [MaterialCode])
);
GO

