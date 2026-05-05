CREATE TABLE [dbo].[SpareParts] (
    [Id] INT IDENTITY(1,1) NOT NULL DEFAULT ,
    [EquipmentId] INT NOT NULL DEFAULT ,
    [PartName] NVARCHAR(MAX) NULL DEFAULT ,
    [PartNumber] NVARCHAR(MAX) NULL DEFAULT ,
    [Specification] NVARCHAR(MAX) NULL DEFAULT ,
    [Quantity] INT NULL DEFAULT ,
    [ReplacementParts] NVARCHAR(MAX) NULL DEFAULT ,
    [Inspector] NVARCHAR(MAX) NULL DEFAULT ,
    [Remarks] NVARCHAR(MAX) NULL DEFAULT ,
    [FailureHistory] NVARCHAR(MAX) NULL DEFAULT ,
    [CreationTime] DATETIME2 NULL DEFAULT 
);
GO

