CREATE TABLE [dbo].[STB_ElectrodeStep] (
    [ProdCode] VARCHAR(20) NOT NULL DEFAULT ,
    [seq] INT NOT NULL DEFAULT ,
    [ElectrodeStepCode] VARCHAR(10) NOT NULL DEFAULT ,
    [MaterialCode] VARCHAR(20) NOT NULL DEFAULT ,
    [StdMinVal] NUMERIC(20,5) NULL DEFAULT ,
    [StdMaxVal] NUMERIC(20,5) NULL DEFAULT ,
    [WorkTime] NUMERIC(20,5) NULL DEFAULT ,
    [HighSpeedSpin] NUMERIC(20,5) NULL DEFAULT ,
    [LowSpeedSpin] NUMERIC(20,5) NULL DEFAULT ,
    [Remark] VARCHAR(500) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    CONSTRAINT [PK_STB_ElectrodeStep] PRIMARY KEY CLUSTERED ([ProdCode], [seq], [ElectrodeStepCode], [MaterialCode])
);
GO

