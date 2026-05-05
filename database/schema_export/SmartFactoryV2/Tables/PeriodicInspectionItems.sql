CREATE TABLE [dbo].[PeriodicInspectionItems] (
    [Id] INT IDENTITY(1,1) NOT NULL DEFAULT ,
    [EquipmentId] INT NOT NULL DEFAULT ,
    [InspectionInterval] NVARCHAR(MAX) NULL DEFAULT ,
    [PeriodicItems] NVARCHAR(MAX) NULL DEFAULT ,
    [DateOfInspection] DATETIME2 NULL DEFAULT ,
    [InspectionDetails] NVARCHAR(MAX) NULL DEFAULT 
);
GO

