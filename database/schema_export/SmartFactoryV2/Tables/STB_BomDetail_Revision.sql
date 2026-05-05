CREATE TABLE [dbo].[STB_BomDetail_Revision] (
    [MaterialCode] VARCHAR(50) NOT NULL DEFAULT ,
    [BomVersion] VARCHAR(20) NOT NULL DEFAULT ,
    [ChildMaterialCode] VARCHAR(50) NOT NULL DEFAULT ,
    [ChildBomVersion] VARCHAR(20) NOT NULL DEFAULT ,
    [ChildRevision] VARCHAR(20) NOT NULL DEFAULT ,
    [FindNum] VARCHAR(50) NULL DEFAULT ,
    [RefDes] VARCHAR(4000) NULL DEFAULT ,
    [TextRefDes] VARCHAR(4000) NULL DEFAULT ,
    [ValidFrom] DATETIME NOT NULL DEFAULT ,
    [ValidTo] DATETIME NOT NULL DEFAULT ('9999-12-31'),
    [DocumentSaveCode] VARCHAR(50) NULL DEFAULT ,
    [EndDocumentSaveCode] VARCHAR(50) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    CONSTRAINT [PK_STB_BomDetail_Revision] PRIMARY KEY CLUSTERED ([MaterialCode], [BomVersion], [ChildMaterialCode], [ChildBomVersion], [ChildRevision])
);
GO

