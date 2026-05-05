CREATE TABLE [dbo].[STB_BomRevision_Map] (
    [MaterialCode] VARCHAR(50) NOT NULL DEFAULT ,
    [BomVersion] VARCHAR(20) NOT NULL DEFAULT ,
    [CustomerRevision] VARCHAR(20) NOT NULL DEFAULT ,
    [IsActive] BIT NOT NULL DEFAULT ((1)),
    [DocumentSaveCode] VARCHAR(50) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    CONSTRAINT [PK_STB_BomRevision_Map] PRIMARY KEY CLUSTERED ([MaterialCode], [BomVersion])
);
GO

