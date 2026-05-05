CREATE TABLE [dbo].[STB_ElectrodeSlittingCutterUsageHist] (
    [ElectrodeSlittingCutterUsageHistNo] VARCHAR(20) NOT NULL DEFAULT ,
    [BaseDate] DATE NULL DEFAULT ,
    [MachineCode] VARCHAR(20) NULL DEFAULT ,
    [ShiftCode] VARCHAR(20) NULL DEFAULT ,
    [UseQty] NUMERIC(20,5) NULL DEFAULT ,
    [CumulativeQty] NUMERIC(20,5) NULL DEFAULT ,
    [Remark] NVARCHAR(MAX) NULL DEFAULT ,
    [IsExchange] BIT NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

