CREATE TABLE [dbo].[STB_DefectCauseInfo] (
    [DefectCauseCode] VARCHAR(20) NOT NULL DEFAULT ,
    [BasicDefectCauseName] NVARCHAR(50) NULL DEFAULT ,
    [DefectCauseDesc] NVARCHAR(200) NULL DEFAULT ,
    [DefectCauseGroupCode] VARCHAR(20) NULL DEFAULT ,
    [DisplayIndex] INT NULL DEFAULT ,
    [IsUsed] BIT NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

