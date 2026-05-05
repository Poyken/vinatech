CREATE TABLE [dbo].[STB_Reports] (
    [ScreenID] VARCHAR(10) NOT NULL DEFAULT ,
    [SeqNo] VARCHAR(4) NOT NULL DEFAULT ,
    [ReportName] NVARCHAR(100) NULL DEFAULT ,
    [ReportLayout] NVARCHAR(MAX) NULL DEFAULT ,
    [Description] NVARCHAR(MAX) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT (getdate()),
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    CONSTRAINT [PK_STB_Reports] PRIMARY KEY CLUSTERED ([ScreenID], [SeqNo])
);
GO

