CREATE TABLE [dbo].[STB_MaterialMasterToVN] (
    [ID] INT IDENTITY(1,1) NOT NULL DEFAULT ,
    [MaterialCode] VARCHAR(50) NULL DEFAULT ,
    [MaterialCodeVN] VARCHAR(50) NULL DEFAULT ,
    [IsUsed] BIT NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserId] NVARCHAR(50) NULL DEFAULT 
);
GO

