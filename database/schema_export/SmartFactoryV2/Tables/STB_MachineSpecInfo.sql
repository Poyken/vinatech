CREATE TABLE [dbo].[STB_MachineSpecInfo] (
    [MachineSpecSeq] VARCHAR(4) NOT NULL DEFAULT ,
    [MachineCode] VARCHAR(20) NOT NULL DEFAULT ,
    [SpecGroupName] NVARCHAR(100) NULL DEFAULT ,
    [SpecName] NVARCHAR(100) NULL DEFAULT ,
    [SpecText] NVARCHAR(200) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    CONSTRAINT [PK_STB_MachineSpecInfo] PRIMARY KEY CLUSTERED ([MachineSpecSeq], [MachineCode])
);
GO

