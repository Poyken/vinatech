CREATE TABLE [dbo].[STB_ChangeMaterial_HN] (
    [Id] INT IDENTITY(1,1) NOT NULL DEFAULT ,
    [OldMaterialCode] NVARCHAR(50) NOT NULL DEFAULT ,
    [NewMaterialCode] NVARCHAR(50) NOT NULL DEFAULT ,
    [IsActive] BIT NULL DEFAULT ((1)),
    [CreatedBy] NVARCHAR(50) NULL DEFAULT ,
    [CreatedDate] DATETIME NULL DEFAULT (getdate())
);
GO

