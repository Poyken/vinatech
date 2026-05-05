CREATE TABLE [dbo].[STB_SerialInfo] (
    [MaterialCode] VARCHAR(50) NOT NULL DEFAULT ,
    [Header] VARCHAR(20) NOT NULL DEFAULT ,
    [SerialNo] INT NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    [StrSerialNo] VARCHAR(20) NULL DEFAULT ,
    CONSTRAINT [PK_STB_SerialInfo] PRIMARY KEY CLUSTERED ([MaterialCode], [Header])
);
GO

