CREATE TABLE [dbo].[STB_MEABlueprintInfo] (
    [MEABlueprintNo] VARCHAR(20) NOT NULL DEFAULT ,
    [MEABlueprintModelNo] VARCHAR(20) NULL DEFAULT ,
    [MEABlueprintSerNo] INT NULL DEFAULT ,
    [MEAClassCode] VARCHAR(20) NULL DEFAULT ,
    [CathodeCatalystCode] VARCHAR(20) NULL DEFAULT ,
    [AnodeCatalystCode] VARCHAR(20) NULL DEFAULT ,
    [ElectrolyteMembraneCode] VARCHAR(20) NULL DEFAULT ,
    [AreaValue] VARCHAR(10) NULL DEFAULT ,
    [GDLValue] VARCHAR(10) NULL DEFAULT ,
    [BlueprintFileID] BIGINT NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

