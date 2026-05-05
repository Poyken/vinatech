CREATE TABLE [dbo].[STB_PublicCodeAndPrice] (
    [ID] INT IDENTITY(1,1) NOT NULL DEFAULT ,
    [PublicCode] VARCHAR(30) NULL DEFAULT ,
    [Price] NUMERIC(20,18) NULL DEFAULT ,
    [IsUsed] BIT NULL DEFAULT ,
    [WorkCenterCode] VARCHAR(20) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    [OnlyImport] BIT NULL DEFAULT 
);
GO

