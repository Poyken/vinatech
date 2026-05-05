CREATE TABLE [dbo].[STB_UPHTimeSetupInfo] (
    [BaseDate] DATE NOT NULL DEFAULT ,
    [UPHItemCode] VARCHAR(20) NOT NULL DEFAULT ,
    [MachineCode] VARCHAR(20) NOT NULL DEFAULT ,
    [LineCode] VARCHAR(20) NULL DEFAULT ,
    [DayWorkTime] NUMERIC(20,5) NOT NULL DEFAULT ,
    [RequiredTime] NUMERIC(20,5) NOT NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NOT NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    CONSTRAINT [PK_STB_UPHTimeSetupInfo] PRIMARY KEY CLUSTERED ([BaseDate], [UPHItemCode], [MachineCode])
);
GO

