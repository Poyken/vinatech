CREATE TABLE [dbo].[STB_MainAssemblePartWeight] (
    [ControlNo] VARCHAR(20) NOT NULL DEFAULT ,
    [AsmPartCode] VARCHAR(50) NOT NULL DEFAULT ,
    [AsmQty] NUMERIC(20,5) NULL DEFAULT ,
    [AsmWorkerCode] VARCHAR(20) NULL DEFAULT ,
    [AsmMachineCode] VARCHAR(20) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    CONSTRAINT [PK_STB_MainAssemblePartWeight] PRIMARY KEY CLUSTERED ([ControlNo], [AsmPartCode])
);
GO

