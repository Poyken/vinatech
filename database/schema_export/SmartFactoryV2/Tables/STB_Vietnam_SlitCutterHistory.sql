CREATE TABLE [dbo].[STB_Vietnam_SlitCutterHistory] (
    [qrcode] VARCHAR(50) NOT NULL DEFAULT ,
    [barcode] VARCHAR(50) NOT NULL DEFAULT ,
    [createuserid] VARCHAR(50) NULL DEFAULT ,
    [createdatetime] DATETIME NULL DEFAULT (getdate()),
    [changeuserid] VARCHAR(50) NULL DEFAULT ,
    [changedatetime] DATETIME NULL DEFAULT 
);
GO

