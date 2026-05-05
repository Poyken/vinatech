CREATE TABLE [dbo].[ESM_ProdCollectionSetting] (
    [CdCompany] VARCHAR(20) NOT NULL DEFAULT ,
    [CollectionType] VARCHAR(10) NOT NULL DEFAULT ,
    [DayTimeAddLegnth] INT NULL DEFAULT ,
    [DawnAddLegnth] INT NULL DEFAULT ,
    [DayTimeDeleteLegnth] INT NULL DEFAULT ,
    [DawnDeleteLegnth] INT NULL DEFAULT ,
    [DayTimeSleepTime] INT NULL DEFAULT ,
    [DawnSleepTime] INT NULL DEFAULT ,
    [DawnStartTime] INT NULL DEFAULT ,
    [DawnEndTime] INT NULL DEFAULT ,
    [DefectAddLength] INT NULL DEFAULT ,
    [CollectionOverTime] INT NULL DEFAULT ,
    CONSTRAINT [PK_ESM_ProdCollectionSetting] PRIMARY KEY CLUSTERED ([CdCompany], [CollectionType])
);
GO

