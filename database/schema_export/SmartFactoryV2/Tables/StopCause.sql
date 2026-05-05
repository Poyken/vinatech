CREATE TABLE [dbo].[StopCause] (
    [StopCauseID] INT IDENTITY(1,1) NOT NULL DEFAULT ,
    [StopCauseName] NVARCHAR(255) NOT NULL DEFAULT ,
    [IsActive] BIT NOT NULL DEFAULT ((1)),
    [CreatedDate] DATETIME NULL DEFAULT (getdate()),
    [CreatedBy] NVARCHAR(100) NULL DEFAULT 
);
GO

