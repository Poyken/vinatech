CREATE TABLE [dbo].[STB_TypeErrorGroupOfFactory] (
    [ID] INT IDENTITY(1,1) NOT NULL DEFAULT ,
    [TypeErrorCode] VARCHAR(50) NULL DEFAULT ,
    [TypeErrorNameVI] NVARCHAR(50) NULL DEFAULT ,
    [TypeErrorNameEN] NVARCHAR(50) NULL DEFAULT ,
    [CreateDateTime] DATE NULL DEFAULT ,
    [ChangeDateTime] DATE NULL DEFAULT ,
    [CreateUserID] VARCHAR(50) NULL DEFAULT ,
    [ChangeUserID] VARCHAR(50) NULL DEFAULT 
);
GO

