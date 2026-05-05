CREATE TABLE [dbo].[STB_ProductMachine] (
    [MachineCode] VARCHAR(20) NOT NULL DEFAULT ,
    [LineCode] VARCHAR(20) NOT NULL DEFAULT (''),
    [RouteCode] VARCHAR(20) NOT NULL DEFAULT (''),
    [DisplayIndex] INT NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    CONSTRAINT [PK_STB_ProductMachine] PRIMARY KEY CLUSTERED ([MachineCode], [LineCode], [RouteCode])
);
GO

