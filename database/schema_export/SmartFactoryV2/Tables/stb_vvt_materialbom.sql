CREATE TABLE [dbo].[stb_vvt_materialbom] (
    [wipcode] VARCHAR(30) NOT NULL DEFAULT ,
    [part] NVARCHAR(200) NULL DEFAULT ,
    [materialname] NVARCHAR(200) NULL DEFAULT ,
    [materialcode] VARCHAR(30) NOT NULL DEFAULT ,
    [usage] FLOAT NULL DEFAULT ,
    [unit] VARCHAR(20) NULL DEFAULT ,
    [qtycell] FLOAT NULL DEFAULT ,
    [usageok] FLOAT NULL DEFAULT ,
    [semiProductName] NVARCHAR(200) NULL DEFAULT ,
    [size] VARCHAR(30) NULL DEFAULT ,
    [type] VARCHAR(30) NULL DEFAULT ,
    [vol] VARCHAR(30) NULL DEFAULT ,
    [farad] VARCHAR(30) NULL DEFAULT ,
    [routecode] VARCHAR(30) NULL DEFAULT ,
    [createdatetime] DATETIME NULL DEFAULT (getdate())
);
GO

