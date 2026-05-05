CREATE TABLE [dbo].[STB_MoldImprovementSheet] (
    [ImproveHistNo] VARCHAR(20) NOT NULL DEFAULT ,
    [MoldNumber] VARCHAR(50) NULL DEFAULT ,
    [WorkCenterCode] VARCHAR(20) NULL DEFAULT ,
    [ImprovementStep] VARCHAR(1) NULL DEFAULT ,
    [ImprovementType] VARCHAR(1) NULL DEFAULT ,
    [MoldType] VARCHAR(1) NULL DEFAULT ,
    [MoldGrade] VARCHAR(1) NULL DEFAULT ,
    [MoldRoute] VARCHAR(1) NULL DEFAULT ,
    [RegistDate] DATE NULL DEFAULT ,
    [CompleteDate] DATE NULL DEFAULT ,
    [DocFileID] BIGINT NULL DEFAULT ,
    [DocFileName] NVARCHAR(MAX) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    [MoldSeqNo] VARCHAR(10) NULL DEFAULT 
);
GO

