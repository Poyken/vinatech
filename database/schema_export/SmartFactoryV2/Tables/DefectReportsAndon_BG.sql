CREATE TABLE [dbo].[DefectReportsAndon_BG] (
    [Id] INT IDENTITY(1,1) NOT NULL DEFAULT ,
    [LineCode] NVARCHAR(50) NULL DEFAULT ,
    [RouteName] NVARCHAR(255) NULL DEFAULT ,
    [ErrorName] NVARCHAR(255) NULL DEFAULT ,
    [ErrorDescription] NVARCHAR(500) NULL DEFAULT ,
    [DetectedBy] NVARCHAR(50) NULL DEFAULT ,
    [Operator] NVARCHAR(50) NULL DEFAULT ,
    [Reason] NVARCHAR(255) NULL DEFAULT ,
    [MachineRootCause] NVARCHAR(255) NULL DEFAULT ,
    [Countermeasure] NVARCHAR(255) NULL DEFAULT ,
    [Repairer] NVARCHAR(100) NULL DEFAULT ,
    [BeginFix] DATETIME NULL DEFAULT ,
    [FinishFix] DATETIME NULL DEFAULT ,
    [CreatedAt] DATETIME NULL DEFAULT (getdate()),
    [Status] INT NULL DEFAULT ,
    [RepairDuration] INT NULL DEFAULT ,
    [MachineName] NVARCHAR(100) NULL DEFAULT ,
    [IsMailSent] BIT NULL DEFAULT ((0))
);
GO

