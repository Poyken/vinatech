CREATE TABLE [dbo].[STB_QcInspectionGroup] (
    [QcInspectionGroupCode] VARCHAR(20) NOT NULL DEFAULT ,
    [QcInspectionGroupName] NVARCHAR(50) NULL DEFAULT ,
    [QcInspectionGroupDesc] NVARCHAR(200) NULL DEFAULT ,
    [IsUsed] BIT NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

