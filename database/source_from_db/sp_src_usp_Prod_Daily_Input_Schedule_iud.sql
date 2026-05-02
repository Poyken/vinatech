-- ==================================================================
-- Author      : kilee
-- Create date : 2019-09-20
-- Browsable   : true
-- Group       : 2019-09-22  자동실행  (매일 1번 오전 8시31분 자동실행)
-- Description :  
-- Modified    : 
-- [실행문]     : EXEC usp_Prod_Daily_Input_Schedule_iud
-- ==================================================================
CREATE PROC [dbo].[usp_Prod_Daily_Input_Schedule_iud] 		
AS

BEGIN
	SET NOCOUNT ON;

	                -- [프롬투날짜로 여러일수 수동으로 적용시]
					--Declare @StartYmd DATE = '2020-03-26'               -- 지우지말것 (원본백업)
					--Declare @EndYmd DATE = '2020-04-02'                -- 지우지말것 (원본백업)

					--Declare @StartYmd DATE = '2020-04-26'               -- 지우지말것 (원본백업)
					--Declare @EndYmd DATE = '2020-04-30'                -- 지우지말것 (원본백업)

					-- [오늘 당일 적용]
					--Declare @StartYmd DATE = SUBSTRING(CONVERT(VARCHAR(10), GetDate()+1, 121), 0, 11)               -- 명일    : 2019-09-27 / SELECT SUBSTRING(CONVERT(VARCHAR(10), GetDate()+1, 121), 0, 11)
					--Declare @EndYmd  DATE = SUBSTRING(CONVERT(VARCHAR(10), GetDate()+2, 121), 0, 11)               -- 이틀후 : 2019-09-28 / SELECT SUBSTRING(CONVERT(VARCHAR(10), GetDate()+2, 121), 0, 11)

					-- [원본- 전일 적용!!!]
                    Declare @StartYmd DATE = SUBSTRING(CONVERT(VARCHAR(10), GetDate(),    121), 0, 11)                 -- 금일 : 2019-09-26 / SELECT SUBSTRING(CONVERT(VARCHAR(10), GetDate(), 121), 0, 11)
					Declare @EndYmd  DATE = SUBSTRING(CONVERT(VARCHAR(10), GetDate()+1, 121), 0, 11)                 -- 명일 : 2019-09-27 / SELECT SUBSTRING(CONVERT(VARCHAR(10), GetDate()+1, 121), 0, 11)

					
					WHILE @StartYmd <= @EndYmd 

					BEGIN

							-- [사이즈별 생산실적]                                         -- 주석처리부분

							   exec usp_Medium_Daily_Input @StartYmd, 'E-22'

							   exec usp_Medium_Daily_Input @StartYmd, 'E-23'

							   exec usp_Medium_Daily_Input @StartYmd, 'E-24'

							   exec usp_Medium_Daily_Input @StartYmd, 'E-25'

							   exec usp_Medium_Daily_Input @StartYmd, 'E-26'

							   exec usp_Medium_Daily_Input @StartYmd, 'E-27'

							   exec usp_Medium_Daily_Input @StartYmd, 'E-28'


							   -- [베트남 법인] 
							  exec usp_Medium_Daily_Input @StartYmd, 'V-22'

							   exec usp_Medium_Daily_Input @StartYmd, 'V-23'

							   exec usp_Medium_Daily_Input @StartYmd, 'V-24'

							   exec usp_Medium_Daily_Input @StartYmd, 'V-25'

							   exec usp_Medium_Daily_Input @StartYmd, 'V-26'

							   exec usp_Medium_Daily_Input @StartYmd, 'V-27'

							   exec usp_Medium_Daily_Input @StartYmd, 'V-28'
   					   
					
							-- [일일보고실적]                                                -- 주석처리부분
									    
							   --exec usp_CurlingLine_Daily_Input @StartYmd, 'E-22'

							   --exec usp_CurlingLine_Daily_Input @StartYmd, 'E-23'

							   --exec usp_CurlingLine_Daily_Input @StartYmd, 'E-24'

							   --exec usp_CurlingLine_Daily_Input @StartYmd, 'E-25'

							   --exec usp_CurlingLine_Daily_Input @StartYmd, 'E-26'

							   --exec usp_CurlingLine_Daily_Input @StartYmd, 'E-27'

							   --exec usp_CurlingLine_Daily_Input @StartYmd, 'E-28'

                           --------------------------
   
					      SET @StartYmd = DateAdd(Day, 1, @StartYmd)

					END

 END