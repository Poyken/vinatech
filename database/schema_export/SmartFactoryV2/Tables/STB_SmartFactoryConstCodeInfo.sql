CREATE TABLE [dbo].[STB_SmartFactoryConstCodeInfo] (
    [GroupCode] VARCHAR(100) NOT NULL DEFAULT ,
    [ConstName] NVARCHAR(100) NOT NULL DEFAULT ,
    [GroupDescription] NVARCHAR(MAX) NULL DEFAULT ,
    [Description] NVARCHAR(MAX) NULL DEFAULT ,
    [ConstValue] NVARCHAR(MAX) NULL DEFAULT ,
    CONSTRAINT [PK_STB_SmartFactoryConstCodeInfo] PRIMARY KEY CLUSTERED ([GroupCode], [ConstName])
);
GO

