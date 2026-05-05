CREATE TABLE [dbo].[stb_ExportReference_Detail] (
    [ID] INT IDENTITY(1,1) NOT NULL DEFAULT ,
    [ExportReference_ID] INT NULL DEFAULT ,
    [LotNo] VARCHAR(50) NULL DEFAULT ,
    [Quatity] NUMERIC(10,5) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] NVARCHAR(50) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] NVARCHAR(50) NULL DEFAULT ,
    [Description] NVARCHAR(500) NULL DEFAULT ,
    [MaterialCode] NVARCHAR(50) NULL DEFAULT 
);
GO

