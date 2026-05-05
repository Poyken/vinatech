CREATE TABLE [dbo].[EquipmentImages] (
    [Id] INT IDENTITY(1,1) NOT NULL DEFAULT ,
    [EquipmentId] INT NOT NULL DEFAULT ,
    [ImageName] NVARCHAR(MAX) NULL DEFAULT ,
    [RelativePath] NVARCHAR(MAX) NULL DEFAULT ,
    [Type] BIT NULL DEFAULT 
);
GO

