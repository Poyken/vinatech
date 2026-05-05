CREATE TABLE [dbo].[STB_ElectrodeLWMeasureHist] (
    [ElectrodeLotNumber] VARCHAR(20) NOT NULL DEFAULT ,
    [SideCode] CHAR(1) NOT NULL DEFAULT ,
    [MeasureTimeCode] VARCHAR(10) NOT NULL DEFAULT ,
    [Seq] INT NOT NULL DEFAULT ,
    [MeasureValue1] NUMERIC(20,10) NULL DEFAULT ,
    [MeasureValue2] NUMERIC(20,10) NULL DEFAULT ,
    [MeasureValue3] NUMERIC(20,10) NULL DEFAULT ,
    [MeasureValue4] NUMERIC(20,10) NULL DEFAULT ,
    [MeasureValue5] NUMERIC(20,10) NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NOT NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    CONSTRAINT [PK_STB_ElectrodeLWMeasureHist] PRIMARY KEY CLUSTERED ([ElectrodeLotNumber], [SideCode], [MeasureTimeCode], [Seq])
);
GO

