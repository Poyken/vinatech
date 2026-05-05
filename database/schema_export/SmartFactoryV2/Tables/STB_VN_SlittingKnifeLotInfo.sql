CREATE TABLE [dbo].[STB_VN_SlittingKnifeLotInfo] (
    [ID] INT IDENTITY(1,1) NOT NULL DEFAULT ,
    [SlittingKnifeLotID] VARCHAR(30) NULL DEFAULT ,
    [ElectrodeLotNumber] VARCHAR(30) NULL DEFAULT ,
    [Status] NVARCHAR(20) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT 
);
GO

