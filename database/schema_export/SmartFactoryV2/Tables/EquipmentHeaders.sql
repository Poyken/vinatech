CREATE TABLE [dbo].[EquipmentHeaders] (
    [Id] INT IDENTITY(1,1) NOT NULL DEFAULT ,
    [AppliedModelName] NVARCHAR(MAX) NOT NULL DEFAULT ,
    [OperatingConditions] NVARCHAR(MAX) NOT NULL DEFAULT ,
    [ControlNumber] NVARCHAR(MAX) NOT NULL DEFAULT ,
    [EquipmentTitle] NVARCHAR(MAX) NOT NULL DEFAULT ,
    [EquipmentPrice] DECIMAL(18,2) NOT NULL DEFAULT ,
    [InstallationLocation] NVARCHAR(MAX) NOT NULL DEFAULT ,
    [DateOfInstallation] DATETIME2 NULL DEFAULT ,
    [ResponsiblePerson] NVARCHAR(MAX) NULL DEFAULT ,
    [IsDeleted] BIT NOT NULL DEFAULT 
);
GO

