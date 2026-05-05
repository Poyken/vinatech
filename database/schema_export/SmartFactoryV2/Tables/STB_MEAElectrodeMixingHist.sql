CREATE TABLE [dbo].[STB_MEAElectrodeMixingHist] (
    [Barcode] VARCHAR(20) NOT NULL DEFAULT ,
    [MEAMixingStepCode] VARCHAR(20) NOT NULL DEFAULT ,
    [StartDateTime] DATETIME NULL DEFAULT ,
    [EndDateTime] DATETIME NULL DEFAULT ,
    [MachineCode] VARCHAR(20) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    CONSTRAINT [PK_STB_MEAElectrodeMixingHist] PRIMARY KEY CLUSTERED ([Barcode], [MEAMixingStepCode])
);
GO

