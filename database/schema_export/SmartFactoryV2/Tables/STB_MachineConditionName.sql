CREATE TABLE [dbo].[STB_MachineConditionName] (
    [MachineCode] VARCHAR(20) NOT NULL DEFAULT ,
    [ConditionColumnIndex] INT NOT NULL DEFAULT ,
    [ConditionName] NVARCHAR(50) NULL DEFAULT ,
    [IsAlarm] BIT NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    CONSTRAINT [PK_STB_MachineConditionName] PRIMARY KEY CLUSTERED ([MachineCode], [ConditionColumnIndex])
);
GO

