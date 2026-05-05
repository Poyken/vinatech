CREATE TABLE [dbo].[STB_DefectInfo] (
    [DefectCode] VARCHAR(20) NOT NULL DEFAULT ,
    [BasicDefectName] NVARCHAR(MAX) NULL DEFAULT ,
    [DefectDesc] NVARCHAR(200) NULL DEFAULT ,
    [DefectGroupCode] VARCHAR(20) NULL DEFAULT ,
    [UseGroup] NVARCHAR(50) NULL DEFAULT ,
    [DisplayIndex] INT NULL DEFAULT ,
    [IsRealDefect] BIT NULL DEFAULT ,
    [IsUsed] BIT NULL DEFAULT ,
    [DefectImage] BIGINT NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    [DirectlyUnder] NVARCHAR(50) NULL DEFAULT ,
    [WorkCenterCode] VARCHAR(20) NULL DEFAULT ,
    [DefectCause] NVARCHAR(255) NULL DEFAULT ,
    [DefectEnglishName] NVARCHAR(MAX) NULL DEFAULT 
);
GO

