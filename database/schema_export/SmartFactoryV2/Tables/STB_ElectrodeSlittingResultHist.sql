CREATE TABLE [dbo].[STB_ElectrodeSlittingResultHist] (
    [ID] INT IDENTITY(1,1) NOT NULL DEFAULT ,
    [ElectrodeLotNumber] VARCHAR(20) NULL DEFAULT ,
    [Seq] INT NULL DEFAULT ,
    [Flag] VARCHAR(10) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT 
);
GO

