CREATE TABLE [dbo].[STB_MainAssemblePartInfo] (
    [ControlNo] VARCHAR(20) NOT NULL DEFAULT ,
    [AsmSeqNo] INT NOT NULL DEFAULT ,
    [AsmPartType] VARCHAR(20) NULL DEFAULT ,
    [AsmPartCode] VARCHAR(50) NULL DEFAULT ,
    [AsmPartBarcode] VARCHAR(50) NULL DEFAULT ,
    [AsmPartSerialNo] VARCHAR(50) NULL DEFAULT ,
    [AsmQty] INT NULL DEFAULT ,
    [AsmJobDate] DATE NULL DEFAULT ,
    [AsmShiftCode] VARCHAR(1) NULL DEFAULT ,
    [AsmDateTime] DATETIME NULL DEFAULT ,
    [AsmWorkerCode] VARCHAR(20) NULL DEFAULT ,
    [AsmMachineCode] VARCHAR(20) NULL DEFAULT ,
    [AsmLotNo] VARCHAR(50) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    CONSTRAINT [PK_STB_MainAssemblePartInfo] PRIMARY KEY CLUSTERED ([ControlNo], [AsmSeqNo])
);
GO

