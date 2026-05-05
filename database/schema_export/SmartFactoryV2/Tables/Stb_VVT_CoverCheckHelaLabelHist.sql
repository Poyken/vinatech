CREATE TABLE [dbo].[Stb_VVT_CoverCheckHelaLabelHist] (
    [id] INT IDENTITY(1,1) NOT NULL DEFAULT ,
    [lotno] VARCHAR(20) NULL DEFAULT ,
    [inboxlabel] VARCHAR(50) NULL DEFAULT ,
    [materialcode] VARCHAR(50) NULL DEFAULT ,
    [materialname] VARCHAR(200) NULL DEFAULT ,
    [createdate] DATETIME NULL DEFAULT (getdate()),
    [createuser] VARCHAR(50) NULL DEFAULT 
);
GO

