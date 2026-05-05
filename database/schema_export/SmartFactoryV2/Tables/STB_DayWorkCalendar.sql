CREATE TABLE [dbo].[STB_DayWorkCalendar] (
    [DayWorkCalendarNo] VARCHAR(20) NOT NULL DEFAULT ,
    [JobDate] DATE NULL DEFAULT ,
    [CompanyCode] VARCHAR(20) NULL DEFAULT ,
    [WorkCenterCode] VARCHAR(20) NULL DEFAULT ,
    [LineCode] VARCHAR(20) NULL DEFAULT ,
    [RouteCode] VARCHAR(20) NULL DEFAULT ,
    [FacilityRouteCode] VARCHAR(20) NULL DEFAULT ,
    [MachineCode] VARCHAR(20) NULL DEFAULT ,
    [CalendarCode] VARCHAR(10) NULL DEFAULT ,
    [StartDateTime] DATETIME NULL DEFAULT ,
    [EndDateTime] DATETIME NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

