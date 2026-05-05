CREATE TABLE [dbo].[STB_IOQCDefectInfo] (
    [DefectCode] VARCHAR(20) NOT NULL DEFAULT ,
    [BasicDefectName] NVARCHAR(100) NULL DEFAULT ,
    [DefectDesc] NVARCHAR(MAX) NULL DEFAULT ,
    [InspectionDocType] VARCHAR(10) NULL DEFAULT ,
    [IsUsed] BIT NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

