CREATE TABLE [dbo].[STB_VN_SlittingKnifeInUse] (
    [SlittingKnifeLotID] VARCHAR(30) NOT NULL DEFAULT ,
    [SlittingKnifeCode] VARCHAR(30) NULL DEFAULT ,
    [MachineCode] VARCHAR(30) NULL DEFAULT ,
    [UsingStatus] BIT NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [EndDate] DATETIME NULL DEFAULT 
);
GO

