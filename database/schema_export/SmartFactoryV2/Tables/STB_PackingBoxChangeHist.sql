CREATE TABLE [dbo].[STB_PackingBoxChangeHist] (
    [OriginalPackingID] VARCHAR(20) NOT NULL DEFAULT ,
    [NewPackingID] VARCHAR(20) NOT NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NOT NULL DEFAULT ,
    CONSTRAINT [PK_STB_PackingBoxChangeHist] PRIMARY KEY CLUSTERED ([OriginalPackingID], [NewPackingID])
);
GO

