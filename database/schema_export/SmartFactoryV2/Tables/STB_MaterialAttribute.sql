CREATE TABLE [dbo].[STB_MaterialAttribute] (
    [MaterialCode] VARCHAR(50) NOT NULL DEFAULT ,
    [AttribType] VARCHAR(1) NOT NULL DEFAULT ,
    [StockAttrib] VARCHAR(20) NOT NULL DEFAULT ,
    [StockAttribDesc] NVARCHAR(200) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTIme] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    CONSTRAINT [PK_STB_MaterialAttribute] PRIMARY KEY CLUSTERED ([MaterialCode], [AttribType], [StockAttrib])
);
GO

