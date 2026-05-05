CREATE TABLE [dbo].[STB_PackingQtyPerSize] (
    [IDX] INT IDENTITY(1,1) NOT NULL DEFAULT ,
    [ProdSize] VARCHAR(10) NULL DEFAULT ,
    [PackingQty] INT NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    [IsUsed] BIT NULL DEFAULT 
);
GO

