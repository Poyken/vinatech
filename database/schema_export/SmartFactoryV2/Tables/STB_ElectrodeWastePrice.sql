CREATE TABLE [dbo].[STB_ElectrodeWastePrice] (
    [ElectrodeWasteCategory1] VARCHAR(20) NOT NULL DEFAULT ,
    [ElectrodeWasteCategory2] VARCHAR(20) NOT NULL DEFAULT ,
    [ElectrodeWasteCategory3] VARCHAR(20) NOT NULL DEFAULT ,
    [DefectUnitPrice] NUMERIC(20,3) NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NOT NULL DEFAULT ('eai'),
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    CONSTRAINT [PK_STB_ElectrodeWastePrice] PRIMARY KEY CLUSTERED ([ElectrodeWasteCategory1], [ElectrodeWasteCategory2], [ElectrodeWasteCategory3])
);
GO

