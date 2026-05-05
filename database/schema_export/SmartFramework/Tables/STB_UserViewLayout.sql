CREATE TABLE [dbo].[STB_UserViewLayout] (
    [UserID] VARCHAR(20) NOT NULL DEFAULT ,
    [ScreenName] VARCHAR(50) NOT NULL DEFAULT ,
    [ViewName] VARCHAR(100) NOT NULL DEFAULT ,
    [ControlType] VARCHAR(20) NOT NULL DEFAULT ,
    [Layout] NVARCHAR(MAX) NULL DEFAULT ,
    [Settings] NVARCHAR(MAX) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [ChangeDateTime] NCHAR(10) NULL DEFAULT ,
    CONSTRAINT [PK_STB_UserViewLayout] PRIMARY KEY CLUSTERED ([UserID], [ScreenName], [ViewName], [ControlType])
);
GO

