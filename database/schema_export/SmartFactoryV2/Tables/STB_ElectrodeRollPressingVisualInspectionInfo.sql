CREATE TABLE [dbo].[STB_ElectrodeRollPressingVisualInspectionInfo] (
    [ElectrodeLotNumber] VARCHAR(20) NOT NULL DEFAULT ,
    [MeasureTimeCode] VARCHAR(20) NOT NULL DEFAULT ,
    [Seq] INT NOT NULL DEFAULT ,
    [LeftValue] NUMERIC(20,5) NULL DEFAULT ,
    [MiddleValue] NUMERIC(20,5) NULL DEFAULT ,
    [RightValue] NUMERIC(20,5) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    CONSTRAINT [PK_STB_ElectrodeRollPressingVisualInspectionInfo] PRIMARY KEY CLUSTERED ([ElectrodeLotNumber], [MeasureTimeCode], [Seq])
);
GO

