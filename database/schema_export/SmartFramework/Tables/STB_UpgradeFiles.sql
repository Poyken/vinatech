CREATE TABLE [dbo].[STB_UpgradeFiles] (
    [ProgramName] NVARCHAR(50) NOT NULL DEFAULT ,
    [FileName] NVARCHAR(255) NOT NULL DEFAULT ,
    [Platform] VARCHAR(10) NOT NULL DEFAULT ,
    [Version] INT NOT NULL DEFAULT ,
    [FileData] VARBINARY(MAX) NOT NULL DEFAULT ,
    [TargetPath] NVARCHAR(255) NULL DEFAULT ,
    [ExtractZip] BIT NOT NULL DEFAULT ((0)),
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    CONSTRAINT [PK_STB_UpgradeFiles] PRIMARY KEY CLUSTERED ([ProgramName], [FileName], [Platform])
);
GO

