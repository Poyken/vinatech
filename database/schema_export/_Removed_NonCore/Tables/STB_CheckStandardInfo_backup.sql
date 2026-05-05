CREATE TABLE [dbo].[STB_CheckStandardInfo_backup] (
    [CheckStandardNo] VARCHAR(20) NOT NULL DEFAULT ,
    [CheckClassNo] VARCHAR(10) NULL DEFAULT ,
    [LineCode] VARCHAR(20) NULL DEFAULT ,
    [MachineCode] VARCHAR(20) NULL DEFAULT ,
    [CheckPartNo] VARCHAR(20) NULL DEFAULT ,
    [CheckPartPicture1] VARBINARY(MAX) NULL DEFAULT ,
    [CheckPartPicture2] VARBINARY(MAX) NULL DEFAULT ,
    [CheckPartPicture3] VARBINARY(MAX) NULL DEFAULT ,
    [CheckPartPicture4] VARBINARY(MAX) NULL DEFAULT ,
    [CheckPartPicture5] VARBINARY(MAX) NULL DEFAULT ,
    [RelationshipContent] VARCHAR(MAX) NULL DEFAULT ,
    [CheckPartContent] VARCHAR(1000) NULL DEFAULT ,
    [CheckStandard] VARCHAR(1000) NULL DEFAULT ,
    [CheckMethod] VARCHAR(1000) NULL DEFAULT ,
    [CheckRepeatCycleCode] VARCHAR(20) NULL DEFAULT ,
    [CheckStartDate] DATETIME NULL DEFAULT ,
    [CheckTime] DATETIME NULL DEFAULT ,
    [CheckDateOption] VARCHAR(10) NULL DEFAULT ,
    [DayOfWeekCode] INT NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    [IsUsed] BIT NULL DEFAULT ,
    [ImageReferenceNo] VARCHAR(20) NULL DEFAULT 
);
GO

