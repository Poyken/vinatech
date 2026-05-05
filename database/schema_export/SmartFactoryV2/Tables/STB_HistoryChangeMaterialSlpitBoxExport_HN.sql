CREATE TABLE [dbo].[STB_HistoryChangeMaterialSlpitBoxExport_HN] (
    [ID] INT IDENTITY(1,1) NOT NULL DEFAULT ,
    [PackingID] VARCHAR(50) NULL DEFAULT ,
    [OldMaterialCode] VARCHAR(50) NULL DEFAULT ,
    [NewMaterialCode] VARCHAR(50) NULL DEFAULT ,
    [CreateDatetime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(50) NULL DEFAULT 
);
GO

