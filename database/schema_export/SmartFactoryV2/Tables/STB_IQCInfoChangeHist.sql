CREATE TABLE [dbo].[STB_IQCInfoChangeHist] (
    [ID] INT IDENTITY(1,1) NOT NULL DEFAULT ,
    [MaterialQcNo] VARCHAR(20) NULL DEFAULT ,
    [BefPassedSampleQty] INT NULL DEFAULT ,
    [BefDefectSampleQty] INT NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(30) NULL DEFAULT 
);
GO

