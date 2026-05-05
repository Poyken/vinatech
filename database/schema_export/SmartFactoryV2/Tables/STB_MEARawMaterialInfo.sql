CREATE TABLE [dbo].[STB_MEARawMaterialInfo] (
    [MEAClassCode] VARCHAR(20) NOT NULL DEFAULT ,
    [MEARawMaterialClassCode] VARCHAR(20) NOT NULL DEFAULT ,
    [MEARawMaterialCode] VARCHAR(20) NOT NULL DEFAULT ,
    [MEARawMaterialName] NVARCHAR(100) NOT NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    CONSTRAINT [PK_STB_MEARawMaterialInfo] PRIMARY KEY CLUSTERED ([MEAClassCode], [MEARawMaterialClassCode], [MEARawMaterialCode])
);
GO

