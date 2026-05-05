CREATE TABLE [dbo].[STB_RawMaterialBaiscInfo] (
    [SizeCode] VARCHAR(20) NOT NULL DEFAULT ,
    [ProductGroupCode] VARCHAR(20) NOT NULL DEFAULT ,
    [ProductGroupName] VARCHAR(100) NOT NULL DEFAULT ,
    [DisplayIndex] INT NOT NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    [ProductGroupName_VVT] NVARCHAR(100) NULL DEFAULT ,
    CONSTRAINT [PK_STB_RawMaterialBaiscInfo] PRIMARY KEY CLUSTERED ([SizeCode], [ProductGroupCode])
);
GO

