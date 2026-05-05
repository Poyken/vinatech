CREATE TABLE [dbo].[Stb_Vietnam_SlitCutter] (
    [id] INT IDENTITY(1,1) NOT NULL DEFAULT ,
    [qrcode] VARCHAR(50) NULL DEFAULT ,
    [begintime] DATETIME NULL DEFAULT ,
    [endtime] DATETIME NULL DEFAULT ,
    [totalkm] FLOAT NULL DEFAULT ,
    [warn20] DATETIME NULL DEFAULT ,
    [warn40] DATETIME NULL DEFAULT ,
    [warn60] DATETIME NULL DEFAULT ,
    [warn70] DATETIME NULL DEFAULT ,
    [warninglevel] INT NULL DEFAULT ,
    [comment] NVARCHAR(1000) NULL DEFAULT ,
    [historylot] VARCHAR(MAX) NULL DEFAULT ,
    [needcheck] INT NULL DEFAULT ,
    [sendEmail] INT NULL DEFAULT 
);
GO

