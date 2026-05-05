CREATE TABLE [dbo].[STB_VVT_ElecErrorPriceMeter2KG] (
    [defect] VARCHAR(50) NULL DEFAULT ,
    [materialName] VARCHAR(100) NULL DEFAULT ,
    [collecter] VARCHAR(50) NULL DEFAULT ,
    [electrolysis] VARCHAR(50) NULL DEFAULT ,
    [size1] VARCHAR(50) NULL DEFAULT ,
    [size2] VARCHAR(50) NULL DEFAULT ,
    [upricem] VARCHAR(50) NULL DEFAULT ,
    [upricekg] VARCHAR(50) NULL DEFAULT ,
    [m2kg] VARCHAR(50) NULL DEFAULT ,
    [kg2m] VARCHAR(50) NULL DEFAULT ,
    [typenew] VARCHAR(50) NULL DEFAULT ,
    [ID] INT IDENTITY(1,1) NOT NULL DEFAULT ,
    [size] VARCHAR(50) NULL DEFAULT ,
    [distinguish_materialName] VARCHAR(50) NULL DEFAULT 
);
GO

