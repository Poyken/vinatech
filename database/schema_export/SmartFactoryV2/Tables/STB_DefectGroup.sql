CREATE TABLE [dbo].[STB_DefectGroup] (
    [DefectGroupCode] VARCHAR(20) NOT NULL DEFAULT ,
    [BasicDefectGroupName] NVARCHAR(50) NULL DEFAULT ,
    [UseGroup] NVARCHAR(50) NULL DEFAULT ,
    [DisplayIndex] INT NULL DEFAULT ,
    [IsUsed] BIT NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

