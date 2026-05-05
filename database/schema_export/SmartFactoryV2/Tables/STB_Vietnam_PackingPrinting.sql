CREATE TABLE [dbo].[STB_Vietnam_PackingPrinting] (
    [MaterialCode] VARCHAR(50) NOT NULL DEFAULT ,
    [PartNo] VARCHAR(50) NULL DEFAULT ,
    [PrintVJ] BIT NOT NULL DEFAULT ,
    [id] INT IDENTITY(1,1) NOT NULL DEFAULT ,
    [Createdate] DATETIME NULL DEFAULT (getdate()),
    [Createuser] VARCHAR(50) NULL DEFAULT ,
    [Changedate] DATETIME NULL DEFAULT ,
    [Changeuser] VARCHAR(50) NULL DEFAULT ,
    [condition1] VARCHAR(50) NULL DEFAULT ,
    [condition2] VARCHAR(50) NULL DEFAULT ,
    [condition3] VARCHAR(50) NULL DEFAULT ,
    [result1] VARCHAR(50) NULL DEFAULT ,
    [result2] VARCHAR(50) NULL DEFAULT 
);
GO

