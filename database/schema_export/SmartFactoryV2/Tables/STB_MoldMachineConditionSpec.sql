CREATE TABLE [dbo].[STB_MoldMachineConditionSpec] (
    [MachineCode] VARCHAR(20) NOT NULL DEFAULT ,
    [ConditionColumnIndex] INT NOT NULL DEFAULT ,
    [MoldNumber] VARCHAR(50) NOT NULL DEFAULT ,
    [SpecValue] NUMERIC(10,2) NULL DEFAULT ,
    [UpperLimit] NUMERIC(10,2) NULL DEFAULT ,
    [LowerLimit] NUMERIC(10,2) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    CONSTRAINT [PK_STB_MoldMachineConditionSpec] PRIMARY KEY CLUSTERED ([MachineCode], [ConditionColumnIndex], [MoldNumber])
);
GO

