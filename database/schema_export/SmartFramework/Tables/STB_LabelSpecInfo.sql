CREATE TABLE [dbo].[STB_LabelSpecInfo] (
    [LabelType] NVARCHAR(30) NOT NULL DEFAULT ,
    [LabelSpecCode] VARCHAR(30) NOT NULL DEFAULT ,
    [LabelSpecName] NVARCHAR(100) NULL DEFAULT ,
    [LabelSpecDesc] NVARCHAR(200) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    CONSTRAINT [PK_STB_LabelSpecInfo] PRIMARY KEY CLUSTERED ([LabelType], [LabelSpecCode])
);
GO

