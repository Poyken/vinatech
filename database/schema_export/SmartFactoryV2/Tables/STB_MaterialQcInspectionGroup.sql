CREATE TABLE [dbo].[STB_MaterialQcInspectionGroup] (
    [MaterialCode] VARCHAR(50) NOT NULL DEFAULT ,
    [QcInspectionGroupCode] VARCHAR(20) NOT NULL DEFAULT ,
    [GroupInspectionPrior] INT NULL DEFAULT ,
    [GroupReportPrior] INT NULL DEFAULT ,
    [IsUsed] VARCHAR(1) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    CONSTRAINT [PK_STB_MaterialQcInspectionGroup] PRIMARY KEY CLUSTERED ([MaterialCode], [QcInspectionGroupCode])
);
GO

