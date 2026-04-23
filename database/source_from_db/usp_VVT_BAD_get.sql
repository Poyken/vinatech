-- ==================================================================
-- Author      : kilee
-- Create date : 2019-12-13
-- Browsable   : true
-- Group       :  Power-BI 모니터링 화면
-- Description :  DB명 : [SmartFactoryV2]
-- Modified    : Power-BI 대시보드 불량수량 표기부분 (전일, 월말 불량수량부분)
-- ==================================================================

-- [프로시저 실행문]      [usp_VVT_BAD_get]  '','','2020-03-30', '', 'VVT', '2020-03-26', '2020-04-25'

CREATE PROC [dbo].[usp_VVT_BAD_get]
				@pProcessUserID VARCHAR(20),
				@pProcessLanguage VARCHAR(20),
				@pMonth DateTime,
				@pSizeCode VARCHAR(20) = null,
				@pCompanyCode VARCHAR(20) = NULL ,
				
				@pFromDate DATE = NULL,
				@pToDate DATE = NULL                                          
AS

BEGIN
	SET NOCOUNT ON;

	DECLARE @CompanyCode      VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
    DECLARE @ProcessUserID      VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage  VARCHAR(20) = @pProcessLanguage   
	DECLARE @Month               VARCHAR(6) = CONVERT(VARCHAR(6), @pMonth, 112)	                                                            -- SELECT CONVERT(VARCHAR(6), '20200330', 112)	 
	DECLARE @SizeCode            VARCHAR(20) = CASE WHEN ISNULL(@pSizeCode, '') = '' THEN '%' ELSE @pSizeCode END                  -- 전일자 두자리           SELECT  SUBSTRING(CONVERT(VARCHAR(10), GetDate()-1, 121), 9, 2) 	

	--DECLARE @ToDay               VARCHAR(08) = REPLACE(SUBSTRING(CONVERT(VARCHAR(10), GetDate()-1, 121), 0, 11), '-', '')                -- 전일자 두자리           SELECT  REPLACE(SUBSTRING(CONVERT(VARCHAR(10), GetDate()-1, 121), 0, 11), '-', '')   	
	DECLARE @ToDay               VARCHAR(08) = SUBSTRING(CONVERT(VARCHAR(10), GetDate()-1, 121), 0, 11)                -- 전일자 두자리           SELECT  SUBSTRING(CONVERT(VARCHAR(10), GetDate()-1, 121), 0, 11)
	DECLARE @FromDate DATE = @pFromDate
	DECLARE @ToDate    DATE = @pToDate



	--add by Mr.Tung on 12-May-2021 as Vietnam Production Realtime requests
	if(@CompanyCode='VVT')
	begin
				DECLARE @currentdate datetime = DATEADD(DAY,0,getdate()	)
				DECLARE @fullToday     varchar(10) = convert( varchar(10),DATEADD(DAY,1,@currentdate),120)			
					if(DAY(@currentdate)>25) 
						begin 
							select @currentdate = convert( varchar(10),DATEADD(MONTH,1, @currentdate),120) 
						end 

				--	select @ToDay = DAY (@currentdate)
				select @Month = replace(convert( varchar(7),DATEADD(MONTH,0, @currentdate),120),'-','')
					DECLARE @tmpdate    varchar(10) = convert(varchar(10),@currentdate,120)	
					DECLARE @jodatefrom varchar(10)= convert( varchar(7),DATEADD(MONTH,-1, @tmpdate),120) + '-26'
					DECLARE @jodateto   varchar(10)= convert( varchar(7),DATEADD(MONTH, 0, @tmpdate),120) + '-26'
	
			select	 @FromDate  = @jodatefrom + ' 10:30:00'   
			select	 @ToDate     = @jodateto +' 10:30:00'					
	end

	

	-- 2020.03.31
	 SELECT SUM(AA.DAILY_SUM)     AS DAILY_SUM
	               ,  SUM(AA.MONTH_SUM)  AS MONTH_SUM

             FROM (
						-- 전일
						SELECT						
							      SUM(DRI.DefectQty - DRI.RepairQty) AS DAILY_SUM
								  ,                                        0 AS MONTH_SUM
						FROM
													  STB_DefectRepairInfo DRI WITH(NOLOCK)                                                                                             
								LEFT OUTER JOIN STB_MaterialMaster  MM WITH(NOLOCK)						ON MM.MaterialCode = DRI.MaterialCode
								LEFT OUTER JOIN STB_SetInfo SI WITH(NOLOCK)									ON SI.ControlNo = DRI.ControlNo
								LEFT OUTER JOIN STB_LineInfo FLI WITH(NOLOCK)								ON FLI.LineCode = DRI.FindLineCode
								LEFT OUTER JOIN STB_RouteInfo RI WITH(NOLOCK)								ON RI.RouteCode = DRI.FindRouteCode			
								LEFT OUTER JOIN STB_DefectInfo DI WITH(NOLOCK)								ON DI.DefectCode = DRI.DefectCode			
								LEFT OUTER JOIN STB_DefectCauseInfo DCI WITH(NOLOCK)						ON DCI.DefectCauseCode = DRI.DefectCauseCode			
								LEFT OUTER JOIN STB_CustomerInfo CUI WITH(NOLOCK)						ON CUI.CustomerCode = DRI.DutyVendorCode
								LEFT OUTER JOIN VW_RepairType RT												ON RT.RepairType = DRI.RepairType
								LEFT OUTER JOIN VW_DefectCauseType DCT										ON DCT.DefectCauseType = DRI.DefectCauseType
								LEFT OUTER JOIN SmartFramework.dbo.STB_UserInfo UI WITH(NOLOCK)		ON UI.UserID = DRI.RepairUserID
								LEFT OUTER JOIN VW_ShiftCode VFSC WITH(NOLOCK)							ON VFSC.ShiftCode = DRI.FindShiftCode
								LEFT OUTER JOIN VW_ShiftCode VCSC WITH(NOLOCK)							ON VCSC.ShiftCode = DRI.CauseShiftCode			
								LEFT OUTER JOIN STB_ProdRouteHist PRH  WITH(NOLOCK)                    ON PRH.ControlNo = DRI.ControlNo                AND PRH.RouteCode = DRI.FindRouteCode    -- 2019.09.17 추가 조인
								LEFT OUTER JOIN STB_ProdWorkerInfo PWI ON PRH.WorkerCode = PWI.WorkerCode
								LEFT OUTER JOIN STB_MaterialQcInfo MQI ON MQI.MaterialQcNo = SI.LotNumber
						WHERE 1=1
								AND (DRI.CompanyCode LIKE @CompanyCode) 
								--AND	(DRI.WorkCenterCode LIKE @WorkCenterCode) 			
								--AND	(@MaterialCode = '*' OR DRI.MaterialCode = @MaterialCode)
								--AND	(@LineCode = '*' OR DRI.FindLineCode IN (SELECT Item FROM dbo.fnSplitToTable(',',@LineCode))) 
								----AND	DRI.FindJobdate BETWEEN @FromDate AND @ToDate
								--AND	DRI.RepairType NOT IN ('MISSING')
								--AND (@FindRouteCode = '*' OR DRI.FindRouteCode = @FindRouteCode)                                      
								--AND (@DefectCode = '*' OR DRI.DefectCode = @DefectCode)             
								                                       
								 --AND DRI.FindJobdate  = '2020-03-31'
								 AND	DRI.FindJobdate = SUBSTRING(CONVERT(VARCHAR(10), GetDate()-1, 121), 0, 11)       --2020.03.31 추가사항

								 --AND DRI.FindJobdate  = @ToDay

				                -- AND DRI.FindJobdate  LIKE @ToDay + '%'
								-- AND Convert(VARCHAR(10), DRI.FindJobdate, 121)  = @ToDay 
								-- AND Convert(VARCHAR(10), DRI.FindJobdate, 121)  LIKE @ToDay + '%'
					          
						UNION 


						SELECT				
						                                                  0  AS DAILY_SUM		
							    , SUM(DRI.DefectQty - DRI.RepairQty) AS MONTH_SUM
						FROM
													  STB_DefectRepairInfo DRI WITH(NOLOCK)                                                                                             
								LEFT OUTER JOIN STB_MaterialMaster  MM WITH(NOLOCK)						ON MM.MaterialCode = DRI.MaterialCode
								LEFT OUTER JOIN STB_SetInfo SI WITH(NOLOCK)									ON SI.ControlNo = DRI.ControlNo
								LEFT OUTER JOIN STB_LineInfo FLI WITH(NOLOCK)								ON FLI.LineCode = DRI.FindLineCode
								LEFT OUTER JOIN STB_RouteInfo RI WITH(NOLOCK)								ON RI.RouteCode = DRI.FindRouteCode			
								LEFT OUTER JOIN STB_DefectInfo DI WITH(NOLOCK)								ON DI.DefectCode = DRI.DefectCode			
								LEFT OUTER JOIN STB_DefectCauseInfo DCI WITH(NOLOCK)						ON DCI.DefectCauseCode = DRI.DefectCauseCode			
								LEFT OUTER JOIN STB_CustomerInfo CUI WITH(NOLOCK)						ON CUI.CustomerCode = DRI.DutyVendorCode
								LEFT OUTER JOIN VW_RepairType RT												ON RT.RepairType = DRI.RepairType
								LEFT OUTER JOIN VW_DefectCauseType DCT										ON DCT.DefectCauseType = DRI.DefectCauseType
								LEFT OUTER JOIN SmartFramework.dbo.STB_UserInfo UI WITH(NOLOCK)		ON UI.UserID = DRI.RepairUserID
								LEFT OUTER JOIN VW_ShiftCode VFSC WITH(NOLOCK)							ON VFSC.ShiftCode = DRI.FindShiftCode
								LEFT OUTER JOIN VW_ShiftCode VCSC WITH(NOLOCK)							ON VCSC.ShiftCode = DRI.CauseShiftCode			
								LEFT OUTER JOIN STB_ProdRouteHist PRH  WITH(NOLOCK)                    ON PRH.ControlNo = DRI.ControlNo                AND PRH.RouteCode = DRI.FindRouteCode    -- 2019.09.17 추가 조인
								LEFT OUTER JOIN STB_ProdWorkerInfo PWI ON PRH.WorkerCode = PWI.WorkerCode
								LEFT OUTER JOIN STB_MaterialQcInfo MQI ON MQI.MaterialQcNo = SI.LotNumber
						WHERE 1=1
								AND (DRI.CompanyCode LIKE @CompanyCode) 
								--AND	(DRI.WorkCenterCode LIKE @WorkCenterCode) 			
								--AND	(@MaterialCode = '*' OR DRI.MaterialCode = @MaterialCode)
								--AND	(@LineCode = '*' OR DRI.FindLineCode IN (SELECT Item FROM dbo.fnSplitToTable(',',@LineCode))) 
								AND	DRI.FindJobdate BETWEEN @FromDate AND @ToDate
								--AND	DRI.RepairType NOT IN ('MISSING')
								--AND (@FindRouteCode = '*' OR DRI.FindRouteCode = @FindRouteCode)                                      
								--AND (@DefectCode = '*' OR DRI.DefectCode = @DefectCode)         

								 ) AA
	



	-- 원본백업2
	 --SELECT SUM(AA.DAILY_SUM)     AS DAILY_SUM
	 --       ,  SUM(AA.MONTH_SUM)  AS MONTH_SUM

  --   FROM (

	 --         -- 일일불량현황
		--		SELECT  CASE WHEN SUM(QTY) = NULL  OR  SUM(QTY) IS NULL  THEN 0  ELSE   SUM(QTY)	END    AS DAILY_SUM
		--			     , 0                                                                                                             AS MONTH_SUM
		--		FROM STB_BAD_LIST2
		--		WHERE 1=1					
		--		   AND StandardDate LIKE @ToDay + '%'
		--		-- AND StandardDate = '20200102'                                                                                                                       -- 주석처리

		--		UNION 
              
		--	  -- 월간불량현황
		--		SELECT  0                         AS DAILY_SUM
		--				, SUM(ISNULL(QTY, 0))	 AS MONTH_SUM					  
		--		FROM STB_BAD_LIST2
		--		WHERE 1=1					
		--		     AND standardDate LIKE '202004' + '%'  
					 
					 
		--			 OR standardDate IN ('20200326', '20200327','20200328','20200329','20200330','20200331')                --- 해결해야될 사항
		--		--   AND StandardDate LIKE @Month + '%'   OR StandardDate IN ('20191226', '20191227','20191228','20191229','20191230','20191231')       -- 26일부터 말일까지 포함시켜야 됨 (해결과제)
		--		-- AND StandardDate LIKE '202001%'                                                                                                                          -- 주석처리

		--	 ) AA


	
	---- 원본백업1
	-- SELECT SUM(AA.DAILY_SUM)     AS DAILY_SUM
	--        ,  SUM(AA.MONTH_SUM)  AS MONTH_SUM

 --    FROM (

	--          -- 일일불량현황
	--			SELECT  CASE WHEN SUM(QTY) = NULL  OR  SUM(QTY) IS NULL  THEN 0  ELSE   SUM(QTY)	END    AS DAILY_SUM
	--				     , 0                                                                                                             AS MONTH_SUM
	--			FROM STB_BAD_LIST2
	--			WHERE 1=1					
	--			   AND StandardDate LIKE @ToDay + '%'
	--			-- AND StandardDate = '20200102'                                                                                                                       -- 주석처리

	--			UNION 
              
	--		  -- 월간불량현황
	--			SELECT  0                         AS DAILY_SUM
	--					, SUM(ISNULL(QTY, 0))	 AS MONTH_SUM					  
	--			FROM STB_BAD_LIST2
	--			WHERE 1=1					
	--			     AND standardDate LIKE @Month + '%'  OR standardDate IN ('20200326', '20200327','20200328','20200329','20200330','20200331')                --- 해결해야될 사항
	--			--   AND StandardDate LIKE @Month + '%'   OR StandardDate IN ('20191226', '20191227','20191228','20191229','20191230','20191231')       -- 26일부터 말일까지 포함시켜야 됨 (해결과제)
	--			-- AND StandardDate LIKE '202001%'                                                                                                                          -- 주석처리

	--		 ) AA

 END


 --SELECT BaseMonth
--  into #TEMP_TABLE 
-- FROM STB_AggregationPeriod
--WHERE 1=1
--   AND  FromDate  <= @OneDay
--   AND  ToDate     >= @OneDay



---- [데이터검증]
--SELECT Bad_Kind
--		, Sum(qty)
--FROM STB_BAD_LIST2
--WHERE 1=1
--AND StandardDate  IN ('20200326', '20200327','20200328','20200329','20200330','20200331') 
--Group by  Bad_Kind