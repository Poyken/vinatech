CREATE TABLE [dbo].[STB_E_SR_VVT] (
    [id] INT IDENTITY(1,1) NOT NULL DEFAULT ,
    [machinecode] VARCHAR(20) NOT NULL DEFAULT ,
    [ip] VARCHAR(20) NOT NULL DEFAULT ,
    [inspectvalue] FLOAT NOT NULL DEFAULT ,
    [inspectvalue1] FLOAT NULL DEFAULT ,
    [inspectvalue2] FLOAT NULL DEFAULT ,
    [inspectvalue3] FLOAT NULL DEFAULT ,
    [inspectvalue4] FLOAT NULL DEFAULT ,
    [inspectvalue5] FLOAT NULL DEFAULT ,
    [inspectime] VARCHAR(25) NOT NULL DEFAULT ,
    [line_num] VARCHAR(20) NULL DEFAULT ,
    [linecode] VARCHAR(30) NULL DEFAULT ,
    [materialcode] VARCHAR(30) NULL DEFAULT 
);
GO

