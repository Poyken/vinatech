CREATE TABLE [dbo].[STB_UserBasicPermission] (
    [UserID] VARCHAR(20) NOT NULL DEFAULT ,
    [ScreenID] VARCHAR(10) NOT NULL DEFAULT ,
    [AllowView] BIT NULL DEFAULT ,
    [AllowAdd] BIT NULL DEFAULT ,
    [AllowModify] BIT NULL DEFAULT ,
    [AllowDelete] BIT NULL DEFAULT ,
    CONSTRAINT [PK_STB_UserBasicPermission] PRIMARY KEY CLUSTERED ([UserID], [ScreenID])
);
GO

