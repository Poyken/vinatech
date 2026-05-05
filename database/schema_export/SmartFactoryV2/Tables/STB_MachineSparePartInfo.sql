CREATE TABLE [dbo].[STB_MachineSparePartInfo] (
    [MachineCode] VARCHAR(20) NOT NULL DEFAULT ,
    [SparePartCode] VARCHAR(20) NOT NULL DEFAULT ,
    [ChangePlanType] VARCHAR(20) NULL DEFAULT ,
    [ChangePlan] BIGINT NULL DEFAULT ,
    [LastChangeDate] DATE NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTIme] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    CONSTRAINT [PK_STB_MachineSparePartInfo] PRIMARY KEY CLUSTERED ([MachineCode], [SparePartCode])
);
GO

