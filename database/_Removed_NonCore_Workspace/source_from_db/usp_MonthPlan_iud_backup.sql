-- =============================================
-- Author: kilee
-- Create date: 2020-04-23
-- Browsable : true
-- Group : 생산관리 > 공정달력 > 사이즈별 생산목표 
-- Description: 매월 25일부터 자동 Insert
-- Modified:

-- 프로시저 실행 :  usp_MonthPlan_iud '',''
-- =============================================
Create PROCEDURE [dbo].[usp_MonthPlan_iud_backup]
	                    @pProcessUserID VARCHAR(20),
	                    @pProcessLanguage VARCHAR(20)
AS

BEGIN
	SET NOCOUNT ON;

	

	DECLARE @OneDay     VARCHAR(11) = Substring(Convert(Varchar(10), GetDate()-1, 121), 0, 11)                                                    --  [어제] Select Substring(Convert(Varchar(10), GetDate()-1, 121), 0, 11)  
	DECLARE @BaseYm     VARCHAR(06)
	DECLARE @NextYm     VARCHAR(06) = Convert(Varchar(6), DateAdd(Month,1,Getdate()), 112)                                                     -- [다음달] Select Convert(Varchar(6), DateAdd(Month,1,Getdate()), 112)   -- [이번달] Select Convert(VARCHAR(6), GetDate(), 112)
	DECLARE @PreMonth  VARCHAR(11) = Substring(Convert(Varchar(10), GetDate()-1, 121), 0, 11)                                                    --           Select Convert(Varchar(20), GetDate(), 121)
															
		--- 기준년월 (26일부터 ~ 다음달 25일까지)                                         Select * From STB_AggregationPeriod
			SELECT @BaseYm = Replace(BaseMonth, '-', '') 																		
			FROM STB_AggregationPeriod
  			WHERE 1=1									
			   And FromDate  <= @OneDay
			   And ToDate     >= @OneDay															

			   --- 테스트용 (주석부분)
			--   SELECT  Replace(BaseMonth, '-', '') 																		
			--FROM STB_AggregationPeriod
  	--		WHERE 1=1									
			--   And FromDate  <= '2021-08-25'
			--   And ToDate     >=  '2021-08-25'			
    
-- 3개 Table 조회용
	--Select * From  MEDIUM_PLAN  Where 기준년월 = '202005' Order By 기준년월, 사이즈, 공정코드	
	--Select * From  MEDIUM_PROD Where  기준년월 = '202005' Order By 기준년월, 사이즈, RouteCode
	--Select * From Curling_Prod     Where  기준년월 = '202005' Order By 기준년월, 사이즈, RouteCode


	-- 1. 계획Table : MEDIUM_PLAN
			INSERT INTO MEDIUM_PLAN (기준년월, 사이즈, 공정코드
												, Day01, Day02, Day03, Day04, Day05, Day06, Day07, Day08, Day09, Day10, Day11, Day12, Day13, Day14, Day15, Day16, Day17, Day18, Day19, Day20, Day21, Day22, Day23, Day24, Day25, Day26, Day27, Day28, Day29, Day30, Day31
												, CompanyCode,  LineCode )
			SELECT  @NextYm, 사이즈, 공정코드
					 , '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0'
					 , CompanyCode,  LineCode
			 FROM  MEDIUM_PLAN
			WHERE  기준년월 = Replace(@BaseYm, '-', '') 

	-- 2. 실적Table : MEDIUM_PROD
			INSERT INTO MEDIUM_PROD (기준년월, 사이즈, RouteCode, Day01, Day02, Day03, Day04, Day05, Day06, Day07, Day08, Day09, Day10, Day11, Day12, Day13, Day14, Day15, Day16, Day17, Day18, Day19, 
						   Day20, Day21, Day22, Day23, Day24, Day25, Day26, Day27, Day28, Day29, Day30, Day31, CompanyCode,  LineCode )

			SELECT    @NextYm, 사이즈, 공정코드, '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 
						   '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', CompanyCode,  LineCode
			FROM     MEDIUM_PLAN
			WHERE  기준년월 = Replace(@BaseYm, '-', '') 

	-- 3. CURLING_PROD
			--INSERT INTO CURLING_PROD (기준년월, 사이즈, RouteCode, Day01, Day02, Day03, Day04, Day05, Day06, Day07, Day08, Day09, Day10, Day11, Day12, Day13, Day14, Day15, Day16, Day17, Day18, Day19, 
			--			   Day20, Day21, Day22, Day23, Day24, Day25, Day26, Day27, Day28, Day29, Day30, Day31, CompanyCode,  라인코드 )

			--SELECT   @NextYm, 사이즈, 공정코드, '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 
			--			   '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', CompanyCode,  LineCode
			--FROM     MEDIUM_PLAN
			--WHERE  기준년월 = Replace(@BaseYm, '-', '') 

END