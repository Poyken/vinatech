CREATE TABLE [dbo].[STB_DayWorkCalendarDetail] (
    [DayWorkCalendarNo] VARCHAR(20) NOT NULL DEFAULT ,
    [SeqNo] VARCHAR(4) NOT NULL DEFAULT ,
    [ShiftCode] VARCHAR(1) NULL DEFAULT ,
    [TimeCode] VARCHAR(2) NULL DEFAULT ,
    [StartDateTime] DATETIME NULL DEFAULT ,
    [EndDateTime] DATETIME NULL DEFAULT ,
    [IsWork] BIT NULL DEFAULT ,
    [RestType] BIT NULL DEFAULT ,
    CONSTRAINT [PK_STB_DayWorkCalendarDetail] PRIMARY KEY CLUSTERED ([DayWorkCalendarNo], [SeqNo])
);
GO

