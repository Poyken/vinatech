CREATE TABLE [dbo].[STB_ModuleLabelInfo] (
    [ModuleSerialNo] VARCHAR(20) NOT NULL DEFAULT ,
    [ProductNo] VARCHAR(20) NOT NULL DEFAULT ,
    [RevisionNo] VARCHAR(20) NOT NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NOT NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    [SingleLotNo] VARCHAR(20) NULL DEFAULT 
);
GO

