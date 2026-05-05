-- Function: fnConvertVarcharToDateTime



-- =============================================
-- Author:        Kim Han Young
-- Create date: 2011-12-17
-- Description:   Convert String to DateTime
--                      e.g '20111217070000' => '2011-12-17 07:00:00'
--                      Year  : yyyy or yy
--                      Month : mm
--                      Day         : dd
--                      Hour  : hh
--                      Minute      : mi
--                      Second      : ss
-- =============================================
CREATE FUNCTION [dbo].[fnConvertVarcharToDateTime]
(
       @pFormat VARCHAR (20),
       @pDateString VARCHAR (20)       
)
RETURNS DATETIME
AS
BEGIN
       DECLARE @YearStartIndex INT,
                   @YearLength INT ,
                   @MonthStartIndex INT ,
                   @DayStartIndex INT ,
                   @HourStartIndex INT ,
                   @MinuteStartIndex INT ,
                   @SecondStartIndex INT ,  
                   @MiliSecondStartIndex INT ,
                   @DateTime DATETIME
                  
       SET @YearStartIndex = CHARINDEX('yyyy' , @pFormat )
       SET @YearLength = 4     
       IF @YearStartIndex <= 0
                   SET @YearStartIndex = CHARINDEX('yy' , @pFormat )
       SET @MonthStartIndex = CHARINDEX('mm' , @pFormat )
       SET @DayStartIndex = CHARINDEX('dd' , @pFormat )
       SET @HourStartIndex = CHARINDEX('hh' , @pFormat )
       SET @MinuteStartIndex = CHARINDEX('mi' , @pFormat )
       SET @SecondStartIndex = CHARINDEX('ss' , @pFormat )
       SET @MiliSecondStartIndex = CHARINDEX('fff' , @pFormat )
      
       SET @DateTime = CASE
                                     WHEN @YearStartIndex <= 0 THEN ''
                                     ELSE SUBSTRING(@pDateString ,@YearStartIndex, @YearLength) + '-'
                               END +
                               CASE
                                     WHEN @MonthStartIndex <= 0 THEN ''
                                     ELSE SUBSTRING(@pDateString ,@MonthStartIndex, 2) + '-'
                               END +
                               CASE
                                     WHEN @DayStartIndex <= 0 THEN ''
                                     ELSE SUBSTRING(@pDateString ,@DayStartIndex, 2)
                               END +
                               CASE
                                     WHEN @HourStartIndex <= 0 THEN ''
                                     ELSE ' ' + SUBSTRING(@pDateString ,@HourStartIndex, 2) + ':'
                               END +
                               CASE
                                     WHEN @MinuteStartIndex <= 0 THEN ''
                                     ELSE SUBSTRING(@pDateString ,@MinuteStartIndex, 2) + ':'
                               END +
                               CASE
                                     WHEN @SecondStartIndex <= 0 THEN ''
                                     ELSE SUBSTRING(@pDateString ,@SecondStartIndex, 2)
                               END +
                               CASE
                                     WHEN @MiliSecondStartIndex <= 0 THEN ''
                                     ELSE '.' + SUBSTRING(@pDateString ,@MiliSecondStartIndex, 3)
                               END
                                    
       RETURN @DateTime

END




GO

