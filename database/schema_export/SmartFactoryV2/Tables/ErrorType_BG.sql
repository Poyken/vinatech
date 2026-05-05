CREATE TABLE [dbo].[ErrorType_BG] (
    [ErrorID] INT IDENTITY(1,1) NOT NULL DEFAULT ,
    [ProcessCode] VARCHAR(50) NOT NULL DEFAULT ,
    [ErrorName] NVARCHAR(255) NOT NULL DEFAULT ,
    [IsActive] BIT NULL DEFAULT ((1)),
    [CreatedDate] DATETIME NULL DEFAULT (getdate()),
    [CreatedBy] NVARCHAR(50) NULL DEFAULT 
);
GO

