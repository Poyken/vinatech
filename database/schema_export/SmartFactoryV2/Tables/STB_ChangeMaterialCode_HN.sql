CREATE TABLE [dbo].[STB_ChangeMaterialCode_HN] (
    [ID] INT IDENTITY(1,1) NOT NULL DEFAULT ,
    [oldMaterialCode] NVARCHAR(50) NULL DEFAULT ,
    [IsUsed] BIT NULL DEFAULT ((1)),
    [CreateDateTime] DATETIME NULL DEFAULT (getdate()),
    [CreateUserID] NVARCHAR(50) NULL DEFAULT ,
    [NewMaterialCode] NVARCHAR(100) NULL DEFAULT ,
    [PackingID] NVARCHAR(100) NULL DEFAULT ,
    [LotID] NVARCHAR(100) NULL DEFAULT 
);
GO

