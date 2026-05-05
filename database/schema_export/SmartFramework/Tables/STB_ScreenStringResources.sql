CREATE TABLE [dbo].[STB_ScreenStringResources] (
    [ScreenName] VARCHAR(50) NOT NULL DEFAULT ,
    [ResourceName] NVARCHAR(200) NOT NULL DEFAULT ,
    CONSTRAINT [PK_STB_ScreenStringResources] PRIMARY KEY CLUSTERED ([ScreenName], [ResourceName])
);
GO

