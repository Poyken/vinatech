CREATE TABLE [dbo].[STB_VVT_ESRDATA] (
    [id] INT IDENTITY(1,1) NOT NULL DEFAULT ,
    [machinecode] VARCHAR(50) NULL DEFAULT ,
    [ip] VARCHAR(100) NULL DEFAULT ,
    [inspectvalue] FLOAT NOT NULL DEFAULT ,
    [inspectvalue1] FLOAT NULL DEFAULT ,
    [inspectvalue2] FLOAT NULL DEFAULT ,
    [inspectvalue3] FLOAT NULL DEFAULT ,
    [inspectvalue4] FLOAT NULL DEFAULT ,
    [inspectvalue5] FLOAT NULL DEFAULT ,
    [inspectime] VARCHAR(25) NOT NULL DEFAULT ,
    [line_num] VARCHAR(20) NULL DEFAULT ,
    [linecode] VARCHAR(30) NULL DEFAULT ,
    [materialcode] VARCHAR(50) NULL DEFAULT ,
    [CompanyCode] VARCHAR(50) NULL DEFAULT ,
    [COMPort] VARCHAR(50) NULL DEFAULT ,
    [inspecttime] DATETIME NULL DEFAULT (getdate())
);
GO

