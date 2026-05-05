CREATE TABLE [dbo].[Process_BG] (
    [ProcessID] INT IDENTITY(1,1) NOT NULL DEFAULT ,
    [ProcessCode] VARCHAR(50) NULL DEFAULT ,
    [ProcessName] NVARCHAR(100) NOT NULL DEFAULT ,
    [IsActive] BIT NULL DEFAULT ((1)),
    [CreatedDate] DATETIME NULL DEFAULT (getdate()),
    [CreatedBy] NVARCHAR(50) NULL DEFAULT 
);
GO

