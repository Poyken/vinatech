CREATE TABLE [dbo].[STB_WeekNumberInfo] (
    [BaseYear] INT NOT NULL DEFAULT ,
    [BaseMonth] INT NOT NULL DEFAULT ,
    [BaseWeekNo] INT NOT NULL DEFAULT ,
    [Monday] DATE NOT NULL DEFAULT ,
    [Friday] DATE NOT NULL DEFAULT ,
    CONSTRAINT [PK_STB_WeekNumberInfo] PRIMARY KEY CLUSTERED ([BaseYear], [BaseMonth], [BaseWeekNo])
);
GO

