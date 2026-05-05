CREATE TABLE [dbo].[STB_CalendarDetail] (
    [CalendarCode] VARCHAR(10) NOT NULL DEFAULT ,
    [SeqNo] VARCHAR(4) NOT NULL DEFAULT ,
    [StartTime] DATETIME NULL DEFAULT ,
    [EndTime] DATETIME NULL DEFAULT ,
    [IsWork] BIT NULL DEFAULT ,
    [RestType] BIT NULL DEFAULT ,
    [ShiftCode] VARCHAR(1) NULL DEFAULT ,
    [TimeCode] VARCHAR(2) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    CONSTRAINT [PK_STB_CalendarDetail] PRIMARY KEY CLUSTERED ([CalendarCode], [SeqNo])
);
GO

