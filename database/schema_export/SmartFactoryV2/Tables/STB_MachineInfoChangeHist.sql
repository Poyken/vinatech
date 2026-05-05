CREATE TABLE [dbo].[STB_MachineInfoChangeHist] (
    [MachineInfoChangeHist] BIGINT IDENTITY(1,1) NOT NULL DEFAULT ,
    [MachineCode] VARCHAR(20) NOT NULL DEFAULT ,
    [BefMachineName] NVARCHAR(100) NULL DEFAULT ,
    [AftMachineName] NVARCHAR(100) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

