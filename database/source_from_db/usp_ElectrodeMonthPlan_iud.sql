-- =============================================
-- Author: kilee
-- Create date: 2021-02-22
-- Browsable : true
-- Group : 생산관리 > 공정달력 > [B160] 월별생산계획정보 (전극위주)
-- Description: 매월 25일부터 자동 Insert
-- Modified:
-- 2021.04.25 변경
-- 프로시저 실행 :  usp_ElectrodeMonthPlan_iud '',''
-- =============================================
CREATE PROCEDURE [dbo].[usp_ElectrodeMonthPlan_iud]
	                    @pProcessUserID VARCHAR(20),
	                    @pProcessLanguage VARCHAR(20)
AS

BEGIN
	SET NOCOUNT ON;

	DECLARE @OneDay     VARCHAR(11) = Substring(Convert(Varchar(10), GetDate()-1, 121), 0, 11)                                                    --  [어제] Select Substring(Convert(Varchar(10), GetDate()-1, 121), 0, 11)  
	DECLARE @BaseYm     VARCHAR(10) 
	--DECLARE @BaseYm2     VARCHAR(12) 
	DECLARE @NextYm     VARCHAR(06) = Convert(Varchar(6), DateAdd(Month,1,Getdate()), 112)                                                     -- [다음달] Select Convert(Varchar(6), DateAdd(Month,1,Getdate()), 112)   -- [이번달] Select Convert(VARCHAR(6), GetDate(), 112)
	DECLARE @PreMonth  VARCHAR(11) = Substring(Convert(Varchar(10), GetDate()-1, 121), 0, 11)                                                    --            Select Convert(Varchar(20), GetDate(), 121)
															
															 
		--- 기준년월 (26일부터 ~ 다음달 25일까지)                                         Select * From STB_AggregationPeriod
			--SELECT @BaseYm = Replace(BaseMonth, '-', '') 		                       -- 원본백업

			SELECT @BaseYm = BaseMonth	+ '-01'															
			FROM STB_AggregationPeriod
  			WHERE 1=1									
			   And FromDate  <= @OneDay
			   And ToDate     >= @OneDay		;
			 			   		
			--  주석부분
			--   	SELECT BaseMonth																
			--       FROM STB_AggregationPeriod
  	        --		WHERE 1=1									
			--   And FromDate  <= '2021-08-24'
			--   And ToDate     >=  '2021-08-24'

           /*
				--주석부분 (일회용)
    		SELECT  @BaseYm =   BaseMonth	+ '-01'																		
				FROM STB_AggregationPeriod
  				WHERE 1=1									
				   And FromDate  <= '2021-12-25'
				   And ToDate     >= '2021-12-25'		
		 */
			   												
-- [조회용]	
	--begin tran
	------ commit
	--select * From  STB_MonthProdPlan  Where PlanYearMonth = '2021-12-01' 
	--Order By PlanYearMonth, LineCode


	print @BaseYm
	-- 1. 계획Table : STB_MonthProdPlan

			INSERT INTO STB_MonthProdPlan ( CompanyCode, WorkCenterCode, PlanYearMonth, MaterialCode, PlanQty, CreateDateTime, LineCode, Batch, MaterialName )

			-- SELECT  CompanyCode , WorkCenterCode, @NextYm + '-01', MaterialCode, PlanQty, GetDate(), LineCode, Batch, MaterialName

			 SELECT  CompanyCode 
			          , WorkCenterCode
					, Substring(@NextYm, 1, 4) + '-' + Substring(@NextYm, 5, 2)  + '-01'       -- 이 부분을 수정할 것.    	--  , '2021-08-01'
			          , MaterialCode
					  , PlanQty
					  , GetDate()
					  , LineCode
					  , Batch
					  , MaterialName
			  FROM  STB_MonthProdPlan
			  WHERE  1=1
			     AND Convert(Varchar(10), PlanYearMonth) = @BaseYm
			 -- AND PlanYearMonth = '2021-11-01'                                 -- 주석처리

END




/*

 -- 참고용 Select문
			Begin Tran
			-- Commit
			-- Rollback
			INSERT INTO STB_MonthProdPlan ( CompanyCode, WorkCenterCode, PlanYearMonth , MaterialCode, PlanQty, CreateDateTime, LineCode, Batch, MaterialName )
-- 테스트 SQL문

-- TEST1> @BaseYm파악

			SELECT BaseMonth							--- @BaseYm = 		'2021-04'									
			FROM STB_AggregationPeriod
  			WHERE 1=1									
			   And FromDate  <= Substring(Convert(Varchar(10), GetDate()-1, 121), 0, 11)    
			   And ToDate     >=Substring(Convert(Varchar(10), GetDate()-1, 121), 0, 11)    	

-- TEST2>
NEXTYN :  SELECT Convert(Varchar(6), DateAdd(Month,1,Getdate()), 112)  

 SELECT  *  --  CompanyCode , WorkCenterCode,  '202105' + '-01', MaterialCode, PlanQty, GetDate(), LineCode, Batch, MaterialName
	FROM  STB_MonthProdPlan
	WHERE  PlanYearMonth ='2021-04-01'


				 SELECT  CompanyCode , WorkCenterCode, '2021' + '-' + '05' + '-01', MaterialCode, PlanQty, GetDate(), LineCode, Batch, MaterialName
			  FROM  STB_MonthProdPlan
			  WHERE  PlanYearMonth = '2021-04' + '-01'


			  -- 수동으로 INSERT 해주는 경우 : select  * FROM  STB_MonthProdPlan  WHERE  PlanYearMonth = '2021-05-01'

			  Begin Tran
			  -- Commit
			  INSERT INTO STB_MonthProdPlan ( CompanyCode, WorkCenterCode, PlanYearMonth, MaterialCode, PlanQty, CreateDateTime, LineCode, Batch, MaterialName )
			   SELECT  CompanyCode , WorkCenterCode,  '2021-05'  + '-01', MaterialCode, PlanQty, GetDate(), LineCode, Batch, MaterialName
			  FROM  STB_MonthProdPlan
			  WHERE  PlanYearMonth = '2021-04' + '-01'


 SELECT  CompanyCode 
			          , WorkCenterCode
					 , '2021-09' + '-01'       -- 이 부분을 수정할 것.
			          , MaterialCode
					  , PlanQty
					  , GetDate()
					  , LineCode
					  , Batch
					  , MaterialName
			  FROM  STB_MonthProdPlan
			  WHERE  1=1
			     AND Convert(Varchar(10), PlanYearMonth) = '2021-08' + '-01'
		
	

	   	SELECT BaseMonth																
			FROM STB_AggregationPeriod
  			WHERE 1=1									
			   And FromDate  <= '2021-08-26'
			   And ToDate     >=  '2021-08-26'	
			  
*/