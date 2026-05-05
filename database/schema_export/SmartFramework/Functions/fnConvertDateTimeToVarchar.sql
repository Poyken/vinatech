-- Function: fnConvertDateTimeToVarchar



-- =============================================
-- Author:        Kim Han Young
-- Create date: 2011-12-21
-- Description:   Convert DateTime to String
--                      e.g '20111217070000' => '2011-12-17 07:00:00'
--                      Year  : yyyy or yy
--                      Month : mm
--                      Day         : dd
--                      Hour  : hh
--                      Minute      : mi
--                      Second      : ss
--                      Mil          : fff
-- =============================================
CREATE FUNCTION [dbo].[fnConvertDateTimeToVarchar]
(
       @pFormat VARCHAR (30),
       @pDateTime DATETIME      
)
RETURNS VARCHAR (MAX)
AS
BEGIN
       DECLARE @Year INT,
                   @Month INT ,
                   @Day INT ,
                   @Hour INT ,
                   @Minute INT ,
                   @Second INT ,
				   @MiliSecond INT,
                   @DateTime VARCHAR (MAX)
                  
       SET @Year = DATEPART(yyyy ,@pDateTime)
       SET @Month = DATEPART(mm ,@pDateTime)
       SET @Day = DATEPART(dd ,@pDateTime)
       SET @Hour = DATEPART(hh ,@pDateTime)
       SET @Minute = DATEPART(mi ,@pDateTime)
       SET @Second = DATEPART(ss ,@pDateTime)
	   SET @MiliSecond = DATEPART(ms,@pDateTime)	-- 2016-06-26 JGH 추가
     
      
       SET @DateTime = @pFormat
       SET @DateTime = REPLACE(@DateTime ,'yyyy', CONVERT(VARCHAR ,@Year))
       SET @DateTime = REPLACE(@DateTime ,'yy', CONVERT(VARCHAR ,@Year - 2000))		-- 2016-06-26 JGH 추가
       SET @DateTime = REPLACE(@DateTime ,'mm',    CASE
                                                                         WHEN @Month < 10 THEN '0'
                                                                         ELSE ''
                                                                   END + CONVERT(VARCHAR ,@Month))
       SET @DateTime = REPLACE(@DateTime ,'dd',    CASE
                                                                         WHEN @Day < 10 THEN '0'
                                                                         ELSE ''
                                                                   END + CONVERT(VARCHAR ,@Day))
       SET @DateTime = REPLACE(@DateTime ,'hh',    CASE
                                                                         WHEN @Hour < 10 THEN '0'
                                                                         ELSE ''
                                                                   END + CONVERT(VARCHAR ,@Hour))
       SET @DateTime = REPLACE(@DateTime ,'mi',    CASE
                                                                         WHEN @Minute < 10 THEN '0'
                                                                         ELSE ''
                                                                   END + CONVERT(VARCHAR ,@Minute))
       SET @DateTime = REPLACE(@DateTime ,'ss',    CASE
                                                                         WHEN @Second < 10 THEN '0'
                                                                         ELSE ''
                                                                   END + CONVERT(VARCHAR ,@Second))
		-- 2016-06-26 JGH 추가
		SET @DateTime = REPLACE(@DateTime,'fff',   CASE
																   WHEN @MiliSecond < 10 THEN '00'
																   WHEN @MiliSecond < 100 THEN '0'
																   ELSE ''
																   END + CONVERT(VARCHAR,@MiliSecond))	
      
       RETURN @DateTime
END




GO

