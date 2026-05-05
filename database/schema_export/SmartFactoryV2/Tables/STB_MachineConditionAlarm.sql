CREATE TABLE [dbo].[STB_MachineConditionAlarm] (
    [MachineCode] VARCHAR(20) NOT NULL DEFAULT ,
    [ConditionColumnIndex] INT NOT NULL DEFAULT ,
    [ConditionParameter] VARCHAR(20) NULL DEFAULT ,
    [UpperLimit] NUMERIC(10,2) NULL DEFAULT ,
    [LowerLimit] NUMERIC(10,2) NULL DEFAULT ,
    [CurrentValue] NUMERIC(10,2) NULL DEFAULT ,
    [IsAlarm] VARCHAR(1) NULL DEFAULT ,
    [LastDateTime] DATETIME NULL DEFAULT ,
    CONSTRAINT [PK_STB_MachineConditionAlarm] PRIMARY KEY CLUSTERED ([MachineCode], [ConditionColumnIndex])
);
GO

