CREATE TABLE [dbo].[STB_MachineCapacity] (
    [MoldNumber] VARCHAR(20) NOT NULL DEFAULT ,
    [MachineCode] VARCHAR(20) NOT NULL DEFAULT ,
    [UPH] NUMERIC(6,2) NULL DEFAULT ,
    [CT] NUMERIC(6,2) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    CONSTRAINT [PK_STB_MachineCapacity] PRIMARY KEY CLUSTERED ([MoldNumber], [MachineCode])
);
GO

