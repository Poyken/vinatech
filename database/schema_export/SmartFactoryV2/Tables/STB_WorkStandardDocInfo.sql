CREATE TABLE [dbo].[STB_WorkStandardDocInfo] (
    [WorkStandardDocNo] VARCHAR(20) NOT NULL DEFAULT ,
    [LineCode] VARCHAR(20) NULL DEFAULT ,
    [MachineCode] VARCHAR(20) NULL DEFAULT ,
    [DocFileNo] INT NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

