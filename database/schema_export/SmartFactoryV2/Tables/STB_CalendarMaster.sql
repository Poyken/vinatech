CREATE TABLE [dbo].[STB_CalendarMaster] (
    [CalendarCode] VARCHAR(10) NOT NULL DEFAULT ,
    [CalendarName] NVARCHAR(100) NULL DEFAULT ,
    [CalendarDesc] NVARCHAR(200) NULL DEFAULT ,
    [IsUsed] BIT NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

