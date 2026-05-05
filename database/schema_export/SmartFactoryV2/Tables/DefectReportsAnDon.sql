CREATE TABLE [dbo].[DefectReportsAnDon] (
    [Id] INT IDENTITY(1,1) NOT NULL DEFAULT ,
    [LineCode] NVARCHAR(50) NULL DEFAULT ,
    [RouteName] NVARCHAR(255) NULL DEFAULT ,
    [ErrorName] NVARCHAR(255) NULL DEFAULT ,
    [ErrorDescription] NVARCHAR(500) NULL DEFAULT ,
    [DetectedBy] NVARCHAR(100) NULL DEFAULT ,
    [Operator] NVARCHAR(100) NULL DEFAULT ,
    [Reason] NVARCHAR(255) NULL DEFAULT ,
    [Countermeasure] NVARCHAR(255) NULL DEFAULT ,
    [Repairer] NVARCHAR(100) NULL DEFAULT ,
    [BeginOccur] DATETIME NULL DEFAULT ,
    [BeginFix] DATETIME NULL DEFAULT ,
    [FinishFix] DATETIME NULL DEFAULT ,
    [RepairDuration] INT NULL DEFAULT ,
    [Status] BIT NULL DEFAULT ((0)),
    [CreatedAt] DATETIME NULL DEFAULT (getdate()),
    [IsMailSent] BIT NULL DEFAULT ((0))
);
GO

