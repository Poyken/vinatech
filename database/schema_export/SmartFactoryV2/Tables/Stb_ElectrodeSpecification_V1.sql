CREATE TABLE [dbo].[Stb_ElectrodeSpecification_V1] (
    [Model] NVARCHAR(50) NOT NULL DEFAULT ,
    [Farad] NVARCHAR(50) NOT NULL DEFAULT ,
    [Cuc] NVARCHAR(50) NOT NULL DEFAULT ,
    [KhoangCachVetMai] DECIMAL(18,3) NULL DEFAULT ,
    [CreatedDate] DATETIME NULL DEFAULT (getdate()),
    [ID] INT IDENTITY(1,1) NOT NULL DEFAULT 
);
GO

