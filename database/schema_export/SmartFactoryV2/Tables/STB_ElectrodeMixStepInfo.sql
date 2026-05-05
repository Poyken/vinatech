CREATE TABLE [dbo].[STB_ElectrodeMixStepInfo] (
    [ElectrodeLotNumber] VARCHAR(20) NOT NULL DEFAULT ,
    [ElectrodeStep] VARCHAR(10) NOT NULL DEFAULT ,
    [Seq] INT NOT NULL DEFAULT ,
    [ElectrodeMaterialCode] VARCHAR(20) NULL DEFAULT ,
    [InputQty1] NUMERIC(20,5) NULL DEFAULT ,
    [InputQty2] NUMERIC(20,5) NULL DEFAULT ,
    [MaterialLotNumber] VARCHAR(150) NULL DEFAULT ,
    [BinderInputTime] DATETIME NULL DEFAULT ,
    [BinderOutputTime] DATETIME NULL DEFAULT ,
    [MixingInputTime] DATETIME NULL DEFAULT ,
    [MixingOutputTime] DATETIME NULL DEFAULT ,
    [SpecInOut] VARCHAR(5) NULL DEFAULT ,
    [SpecOutQty] NUMERIC(20,5) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    CONSTRAINT [PK_STB_ElectrodeMixStepInfo] PRIMARY KEY CLUSTERED ([ElectrodeLotNumber], [ElectrodeStep], [Seq])
);
GO

