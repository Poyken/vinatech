CREATE TABLE [dbo].[Stb_ExportReference] (
    [ID] INT IDENTITY(1,1) NOT NULL DEFAULT ,
    [No] NVARCHAR(50) NULL DEFAULT ,
    [Customer] NVARCHAR(50) NULL DEFAULT ,
    [DateBasic] DATE NULL DEFAULT ,
    [Description] NVARCHAR(500) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] NVARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] NVARCHAR(20) NULL DEFAULT ,
    [status_confirm] BIT NULL DEFAULT 
);
GO

