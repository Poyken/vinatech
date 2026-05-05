CREATE TABLE [dbo].[STB_RawMaterialBaiscInfoF3] (
    [SizeCode] VARCHAR(20) NOT NULL DEFAULT ,
    [ProductGroupCode] VARCHAR(20) NOT NULL DEFAULT ,
    [ProductGroupName] VARCHAR(100) NOT NULL DEFAULT ,
    [DisplayIndex] INT NOT NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    [ProductGroupName_VVT] NVARCHAR(100) NULL DEFAULT 
);
GO

