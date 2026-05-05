CREATE TABLE [dbo].[STB_PaperTypeInfo] (
    [PaperType] NVARCHAR(30) NOT NULL DEFAULT ,
    [PaperTypeName] NVARCHAR(100) NULL DEFAULT ,
    [IsUsed] BIT NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

