CREATE TABLE [dbo].[STB_ModelLabelInfo] (
    [ModelCode] VARCHAR(50) NOT NULL DEFAULT ,
    [LabelType] NVARCHAR(30) NOT NULL DEFAULT ,
    [FormatName] NVARCHAR(30) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    CONSTRAINT [PK_STB_ModelLabelInfo] PRIMARY KEY CLUSTERED ([ModelCode], [LabelType])
);
GO

