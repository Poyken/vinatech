
-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-09-11
-- Browsable : true
-- Group : 모니터링
-- Description:	Dash Board 화면 
-- Modified: 생산현황 테스트 화면
-- =============================================

--  EXEC usp_GetProductionForMonitoring_VNTV3 'monitoring01','','','','','E-22','E-24'                                                           ---> 실행문

CREATE PROCEDURE [dbo].[usp_GetProductionForMonitoring_VNTV3]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = 'VNT',
	@pWorkCenterCode VARCHAR(20) = 'VNT_F1',
	@pLineCode VARCHAR(20) = NULL,
	@pFirstRouteCode VARCHAR(20) = 'E-22',
	@pSecondRouteCode VARCHAR(20) = 'E-24'
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @ProcessUserID VARCHAR(20) =@pProcessUserID
	DECLARE @CompanyCode VARCHAR(20) = @pCompanyCode
	DECLARE @WorkCenterCode VARCHAR(20) = @pWorkCenterCode

	-- UserID로 라인코드를 조합한다.
	DECLARE @LineNo VARCHAR(20) = REPLACE(@ProcessUserID,'monitoring','')     --> '01'
	
					-- SELECT REPLACE('monitoring01','monitoring','')

	--DECLARE @LineCode VARCHAR(20) = CASE WHEN PATINDEX(@ProcessUserID, 'monitoring') > 01 THEN  'ASSYLINE-' + @LineNo ELSE @pLineCode END
	--DECLARE @LineCode VARCHAR(20) = 'ASSYLINE-' + SUBSTRING(@ProcessUserID, 11, 2)
	DECLARE @LineCode VARCHAR(20) = 'ASSYLINE-' + REPLACE(@ProcessUserID, 'monitoring','')               --> ASSYLINE-01

				-- SELECT CASE WHEN PATINDEX('monitoring1', 'monitoring') > 1 THEN  'ASSYLINE-' + '1' ELSE NULL END
				-- SELECT  'ASSYLINE' + SUBSTRING('monitoring01', 11, 2)
				-- SELECT   'ASSYLINE-'  + REPLACE('monitoring01', 'monitoring','')

	DECLARE @FirstRouteCode VARCHAR(20) = @pFirstRouteCode
	DECLARE @SecondRouteCode VARCHAR(20) = @pSecondRouteCode
	
	DECLARE @LineName NVARCHAR(100)
	DECLARE @JobDateShift VARCHAR(20) = dbo.fnGetJobDateShiftTime(GETDATE(),@CompanyCode,@WorkCenterCode,@LineCode,NULL,NULL)
	DECLARE @JobDate DATE = SUBSTRING(@JobDateShift,1,8)
	--SET @JobDate = '2018-08-23'
	DECLARE @ShiftCode VARCHAR(1) = SUBSTRING(@JobDateShift,9,1)             
	--SET @ShiftCode = '1'
	DECLARE @FirstWorkerName NVARCHAR(100)
	DECLARE @SecondWorkerName NVARCHAR(100)
	DECLARE @MaterialName NVARCHAR(100)
	DECLARE @ModelTypeName VARCHAR(50)
	DECLARE @ModelSpec VARCHAR(50)


	SELECT @LineName = LI.LineName
	 FROM STB_LineInfo LI WITH(NOLOCK)
	WHERE LI.LineCode = @LineCode
	

	--SELECT * FROM STB_LineInfo

	SELECT @MaterialName = MBI.ModelName,
			 @ModelTypeName = MBI.MBIExtText03,
			 @ModelSpec = MBI.MBIExtText04 + ' V - ' + MBI.MBIExtText05 + ' F'
	FROM STB_LineRouteMapping LRM WITH(NOLOCK)
			LEFT OUTER JOIN STB_ProdRouteHist PRH WITH(NOLOCK)				ON PRH.ProdRouteHistNo = LRM.ProdRouteHistNo
			LEFT OUTER JOIN STB_ModelBasicInfo MBI WITH(NOLOCK)				ON MBI.ModelCode = PRH.MaterialCode
	WHERE 1=1
	  AND LRM.LineCode = @LineCode 
	  AND	LRM.RouteCode = @FirstRouteCode



	  		--			SELECT MBI.ModelName
					--			, MBI.MBIExtText03
					--			, MBI.MBIExtText04 + ' V - ' + MBI.MBIExtText05 + ' F'
					--			, *
					--FROM STB_LineRouteMapping LRM WITH(NOLOCK)
					--		LEFT OUTER JOIN STB_ProdRouteHist PRH WITH(NOLOCK)				ON PRH.ProdRouteHistNo = LRM.ProdRouteHistNo
					--		LEFT OUTER JOIN STB_ModelBasicInfo MBI WITH(NOLOCK)				ON MBI.ModelCode = PRH.MaterialCode
					--WHERE 1=1	  
					--  AND LRM.LineCode = 'ASSYLINE-01' 
					--  AND	LRM.RouteCode = 'E-22'

					  
					--  --BEGIN TRAN
					--  ----COMMIT
					--  --UPDATE STB_LineRouteMapping
					--  --SET ProdRouteHistNo = '20190215000001'
					--  --WHERE LINECODE = 'ASSYLINE-01' 

					--  SELECT * FROM STB_LineRouteMapping WHERE LINECODE = 'ASSYLINE-01' 
					--  SELECT * FROM STB_ProdRouteHist        WHERE LINECODE = 'ASSYLINE-01'  ORDER BY DAYPLANNO DESC    --20190215000001
					--  SELECT * FROM STB_ModelBasicInfo

	SELECT TOP 1
			@FirstWorkerName = PWI.WorkerName
	FROM STB_LineRouteMapping LRM WITH(NOLOCK)
			INNER JOIN STB_ProdRouteWorkerHist PRWH WITH(NOLOCK)		ON PRWH.ProdRouteHistNo = LRM.ProdRouteHistNo
			INNER JOIN STB_ProdWorkerInfo PWI WITH(NOLOCK)				ON PWI.WorkerCode = PRWH.WorkerCode
	WHERE 1=1
	   AND LRM.LineCode = @LineCode 
	   AND LRM.RouteCode =	@FirstRouteCode

	   -- TEST부분 (추후삭제예정)
	--   SELECT *	
	--FROM STB_LineRouteMapping LRM WITH(NOLOCK)
	--		INNER JOIN STB_ProdRouteWorkerHist PRWH WITH(NOLOCK)		ON PRWH.ProdRouteHistNo = LRM.ProdRouteHistNo
	--		INNER JOIN STB_ProdWorkerInfo PWI WITH(NOLOCK)				ON PWI.WorkerCode = PRWH.WorkerCode
	--WHERE 1=1
	--   AND LRM.LineCode =  'ASSYLINE-01'
	--   AND LRM.RouteCode IN ('E-22', 'E-24')


	--    SELECT ProdRouteHistNo, *  FROM STB_LineRouteMapping WHERE LINECODE = 'ASSYLINE-01'
	--    SELECT * FROM STB_ProdRouteWorkerHist WHERE ProdRouteHistNo = '20190215000001'

	--	--UPDATE STB_ProdRouteWorkerHist
	--	--SET  ProdRouteHistNo = '20190215000001'
	--	--WHERE ProdRouteHistNo = '20180913000010'

	--    SELECT * FROM STB_ProdWorkerInfo


	SELECT
			TOP 1
			@SecondWorkerName = PWI.WorkerName
	FROM
			STB_LineRouteMapping LRM WITH(NOLOCK)
			INNER JOIN STB_ProdRouteWorkerHist PRWH WITH(NOLOCK)				ON PRWH.ProdRouteHistNo = LRM.ProdRouteHistNo
			INNER JOIN STB_ProdWorkerInfo          PWI WITH(NOLOCK)				ON PWI.WorkerCode = PRWH.WorkerCode
	WHERE 1=1
			AND LRM.LineCode = @LineCode 
			AND LRM.RouteCode =	@FirstRouteCode 
			AND PWI.WorkerName <> @FirstWorkerName
	
	DECLARE @Data TABLE
	(
		IDX INT,
		RouteCode VARCHAR(20),
		RouteName NVARCHAR(100),
		PlanQty INT,
		CurrentTarget INT,
		ProdQty INT,
		DefectQty INT
		--ProdRate NUMERIC(12,1),
		--DefectRate NUMERIC(12,1)

	)


		DECLARE @MonData TABLE
	(
		RouteCode2 VARCHAR(20),		
		ProdQty2 INT,
		DefectQty2 INT	
	)

	;WITH ProdPlan AS
	(

	-- ProdPlan (1)
		SELECT
				@FirstRouteCode AS RouteCode,
				DPP.PlanQty        AS PlanQty,
				DPP.CurrentTarget AS CurrentTarget,
				0 AS ProdQty,
				0 AS DefectQty
				--0 AS ProdRate,
				--0 AS DefectRate
		FROM STB_DayProdPlan DPP WITH(NOLOCK)                              -- 생산계획 Table
		WHERE 1=1
		  AND DPP.LineCode = @LineCode 
		  AND	 DPP.PlanDate = @JobDate 		  
		  AND DPP.PlanShiftCode = @ShiftCode

		UNION ALL
      
	  -- ProdPlan (2)
		SELECT
				@SecondRouteCode AS RouteCode,
				DPP.PlanQty            AS PlanQty, 
				DPP.CurrentTarget    AS CurrentTarget,
				0 AS ProdQty,
				0 AS DefectQty
				--0 AS ProdRate,
				--0 AS DefectRate
		FROM 	STB_DayProdPlan DPP WITH(NOLOCK)
		WHERE 1=1
		  AND DPP.LineCode = @LineCode 
		  AND	DPP.PlanDate = @JobDate 
		  AND	DPP.PlanShiftCode = @ShiftCode
		

		-- SELECT * FROM STB_DayProdPlan WHERE LINECODE = 'ASSYLINE-01' ORDER BY PLANDATE DESC
		
		--UPDATE STB_DayProdPlan
		--SET PLANDATE = '2019-03-18'
		--WHERE PLANDATE = '2019-03-10'

		UNION ALL

		 --> STB_ProdRouteSummary
	SELECT	PRS.RouteCode
			   , 0 AS PlanQty
			   , 0 AS CurrentTarget
		     --,	SUM(PRS.OutputQty) AS OutputQty
				, SUM(PRS.OutputQty) AS ProdQty
			    , SUM(PRS.DefectQty)  AS DefectQty
			    --, ISNULL(SUM(PRS.OutputQty),0) / ISNULL(SUM(PRS.InputQty),0) *  100.0   AS ProdRate
			    --, ISNULL(SUM(PRS.DefectQty),0)  / ISNULL(SUM(PRS.InputQty),0) *  100.0   AS DefectRate
		FROM		STB_ProdRouteSummary PRS WITH(NOLOCK)                               -- 생산실적 Table
		WHERE 1=1
		  AND PRS.LineCode = @LineCode 
		  AND PRS.JobDate = @JobDate 
		  AND PRS.ShiftCode = @ShiftCode 
		  AND PRS.RouteCode IN (@FirstRouteCode,@SecondRouteCode)
		GROUP BY     PRS.RouteCode
	)



	--SELECT
	--			PRS.RouteCode
	--			, 0
	--		   , 0
	--	     --,	SUM(PRS.OutputQty) AS OutputQty
	--			, SUM(PRS.OutputQty) AS ProdQty
	--		    , SUM(PRS.DefectQty)  AS DefectQty
	--		   , ISNULL(SUM(PRS.OutputQty),0) / ISNULL(SUM(PRS.INPUTQTY),0) *  100.0    AS ProdRate
	--		   , 0                        AS DefectRate
	--	FROM		STB_ProdRouteSummary PRS WITH(NOLOCK)                               -- 생산실적 Table
	--	WHERE 1=1
	--	  AND 	PRS.LineCode = 'ASSYLINE-01'
	--	  --AND		PRS.ShiftCode = @ShiftCode 
	--	  AND		PRS.RouteCode IN ('E-22','E-24')
	--	GROUP BY     PRS.RouteCode
	

	-- SELECT * FROM STB_ProdRouteSummary WHERE  LINECODE = 'ASSYLINE-01' ORDER BY JOBDATE DESC
	
	--BEGIN TRAN
	----COMMIT
	--UPDATE STB_ProdRouteSummary
	--SET JOBDATE = '2019-03-18'
	--WHERE JOBDATE = '2019-03-17'



-- [Data Table 생성부분]
		INSERT INTO @Data
			SELECT  ROW_NUMBER() OVER (ORDER BY PP.RouteCode)  AS NO
				, PP.RouteCode                             AS RouteCode
				, RI.RouteName                             AS RouteName
				, SUM(PP.PlanQty)          AS PlanQty
				, SUM(PP.CurrentTarget)  AS CurrentTarget
				, SUM(PP.ProdQty)          AS ProdQty
  				, SUM(PP.DefectQty)        AS DefectQty
				--, SUM(ProdRate)             AS ProdRate
				--, SUM(DefectRate)          AS DefectRate

				--, SUM(ROUND(PP.PlanQty, 1))          AS PlanQty
				--, SUM(ROUND(PP.CurrentTarget, 1))  AS CurrentTarget
				--, SUM(ROUND(PP.ProdQty,1))          AS ProdQty
  		--		, SUM(ROUND(PP.DefectQty,1))        AS DefectQty
				--, SUM(ROUND(ProdRate,1))             AS ProdRate
				--, SUM(ROUND(DefectRate,1))          AS DefectRate

				--, CASE WHEN ISNULL(SUM(PP.ProdQty),0)   = 0 
				
		FROM  ProdPlan PP				LEFT OUTER JOIN STB_RouteInfo RI WITH(NOLOCK)			ON RI.RouteCode = PP.RouteCode
		GROUP BY PP.RouteCode,	 RI.RouteName


--->

	;WITH MonPlan AS
	(

		SELECT PRS.RouteCode        AS RouteCode2
				, SUM(PRS.OutputQty) AS ProdQty2
			    , SUM(PRS.DefectQty)  AS DefectQty2			 
		FROM		STB_ProdRouteSummary PRS WITH(NOLOCK)                            
		WHERE 1=1
		--  AND PRS.LineCode = @LineCode                                                 -- 나중에 추가해야 될 부분
		  AND PRS.JobDate  LIKE '201903%'
		  AND PRS.ShiftCode = @ShiftCode 
		  AND PRS.RouteCode IN (@FirstRouteCode,@SecondRouteCode)
		GROUP BY     PRS.RouteCode
	)

			INSERT INTO @MonData
			SELECT  QQ.RouteCode2                   AS RouteCode2
			         ,  SUM(ROUND(QQ.ProdQty2,1)) AS ProdQty2
  				      , SUM(ROUND(QQ.DefectQty2,1)) AS DefectQty2				
		    FROM  MonPlan QQ				LEFT OUTER JOIN STB_RouteInfo RI WITH(NOLOCK)			ON RI.RouteCode = QQ.RouteCode2			
		GROUP BY QQ.RouteCode2

		
-----------------------------------------------------------------------------------------------------   [중요부분] START  -----------------------------------------------------------------------------------------------------------------------------


-- GROUP [0]  ->   ModelTypeName  (VEC)
	SELECT
			'ProdLayout' AS LayoutID,
			1 AS PageNo,
			0 AS GroupID,
			1 AS ID,
			'ModelTypeName' AS ItemID,
			@ModelTypeName AS ItemValue,
			1 AS TextColorID,
			2 AS TextFontID
	UNION ALL

-- GROUP [1]  -> MaterialName 생산품목
	SELECT
			'ProdLayout' AS LayoutID,
			1 AS PageNo,
			1 AS GroupID,
			1 AS ID,
			'MaterialName' AS ItemID,
			@MaterialName AS ItemValue,
			1 AS TextColorID,
			2 AS TextFontID	
	UNION ALL

	SELECT
			'ProdLayout'          AS LayoutID,
			1                       AS PageNo,
			1                       AS GroupID,
			2                       AS ID,
			'MaterialName'       AS ItemID,
			@MaterialName     AS ItemValue,
			1                       AS TextColorID,
			2                       AS TextFontID	 
     UNION ALL

 -- GROUP [2]  -> 시간부분
	SELECT
			'ProdLayout' AS LayoutID,
			1              AS PageNo,
			2              AS GroupID,
			0              AS ID,
			'Current'     AS ItemID,
			CONVERT(VARCHAR(19), GETDATE(), 120) AS ItemValue,                              --시간
			2 AS TextColorID,
			3 AS TextFontID
	UNION ALL


	-- GROUP [3]  -> ProdQty 양품수량    
	SELECT
			'ProdLayout' AS LayoutID,
			1               AS PageNo,
			3               AS GroupID,
			--DT.IDX         AS ID,
			1 AS ID,
			'ProdQty'                                                    AS ItemID,
			CONVERT(VARCHAR(19),   DT.ProdQty) + ' 개'   AS ItemValue,
			1              AS TextColorID,
			2              AS TextFontID
	FROM		@Data DT	
	UNION ALL

	SELECT
			'ProdLayout' AS LayoutID,
			1               AS PageNo,
			3               AS GroupID,
			--DT.IDX         AS ID,
			2 AS ID,
			'ProdQty'                                                 AS ItemID,			
			CONVERT(VARCHAR(19),   DT.ProdQty) + ' 개' AS ItemValue,
			1              AS TextColorID,
			2              AS TextFontID
	FROM 	@Data DT	
	UNION ALL



	-- GROUP [4]  -> DefectQty 불량수량
	SELECT	'ProdLayout' AS LayoutID,
				1 AS PageNo,
				4 AS GroupID,
				--DT.IDX AS ID,
				1 AS ID,
				'DefectQty'                                                      AS ItemID,
				CONVERT(VARCHAR(19),   DT.DefectQty) + ' 개'      AS ItemValue,
				1 AS TextColorID,
				2 AS TextFontID
	FROM		@Data DT	
	UNION ALL

	SELECT	'ProdLayout' AS LayoutID,
				1 AS PageNo,
				4 AS GroupID,
				--DT.IDX AS ID,
				2 AS ID,
				'DefectQty'                                                   AS ItemID,
				CONVERT(VARCHAR(19),   DT.DefectQty) + ' 개'    AS ItemValue,
				1 AS TextColorID,
				2 AS TextFontID
	FROM		@Data DT	
	UNION ALL

-- GROUP [5]  ->WorkerName OP (작업자)
	SELECT
			'ProdLayout' AS LayoutID,
			1 AS PageNo,
			5 AS GroupID,
			1 AS ID,
			'WorkerName' AS ItemID,
			@FirstWorkerName AS ItemValue,
			1 AS TextColorID,
			2 AS TextFontID
	UNION ALL

	SELECT
			'ProdLayout' AS LayoutID,
			1 AS PageNo,
			5 AS GroupID,
			2 AS ID,
			'WorkerName' AS ItemID,
			@SecondWorkerName AS ItemValue,
			1 AS TextColorID,
			2 AS TextFontID
	UNION ALL

---- GROUP [6]  -> ProdRate 수율
--	SELECT
--			'ProdLayout'        AS LayoutID,
--			1                     AS PageNo,
--			6                     AS GroupID,
--			1                     AS ID,
--			'ProdRate'           AS ItemID,			 
--			CONVERT(VARCHAR(19),   DT.ProdRate) + ' %' AS ItemValue,

--			-- '85%'       AS ItemValue,
--			'1'                     AS TextColorID,
--			'2'                     AS TextFontID	
--   FROM
--			@Data DT

--    UNION ALL

 --  -- GROUP [7]  -> DefectRate 달성율
	--SELECT
	--		'ProdLayout'        AS LayoutID,
	--		1                     AS PageNo,
	--		7                     AS GroupID,
	--		1                     AS ID,
	--		DefectRate           AS ItemID,		
	--		CONVERT(VARCHAR(19),   DT.DefectRate) + ' %'    AS ItemValue,
	--		-- '97%'       AS ItemValue,
	--		'1'                     AS TextColorID,
	--		'2'                     AS TextFontID	
	--FROM
	--		@Data DT

 --UNION ALL

  -- GROUP [8]  ->  ItemName  (권취, 조립표시)
	SELECT
			'ProdLayout'          AS LayoutID,
			1                       AS PageNo,
			8                      AS GroupID,
			1                       AS ID,
			'ItemName'           AS ItemID,
			'권취'                 AS ItemValue,
			1                       AS TextColorID,
			2                       AS TextFontID	 							
	 UNION ALL

	SELECT
			'ProdLayout'          AS LayoutID,
			1                       AS PageNo,
			8                      AS GroupID,
			2                       AS ID,
			'ItemName'           AS ItemID,
			'조립'                 AS ItemValue,
			1                       AS TextColorID,
			2                       AS TextFontID			
	 UNION ALL



-- GROUP [9]  -> 맨윗줄 라인정보
	SELECT
			'ProdLayout'                  AS LayoutID,
			1                               AS PageNo,
			9                               AS GroupID,
			1                               AS ID,
			'Explanation'                   AS ItemID,
			@LineName + ' 생산현황' AS ItemValue,                                    --- 셀 1라인 생산현황
			2                              AS TextColorID,
			2                              AS TextFontID
	UNION ALL



	
-- GROUP [10]  ->  Guidance (현재생산품목, 다음생산품목) 문구세팅
	SELECT
			'ProdLayout'          AS LayoutID,
			1                       AS PageNo,
			10                      AS GroupID,
			1                       AS ID,
			'Guidance'           AS ItemID,
			'현재 생산품목'     AS ItemValue,
			2                       AS TextColorID,
			3                       AS TextFontID	 
  UNION ALL

	SELECT
			'ProdLayout'          AS LayoutID,
			1                       AS PageNo,
			10                      AS GroupID,
			2                       AS ID,
			'Guidance'           AS ItemID,
			'다음 생산품목'     AS ItemValue,
			2                       AS TextColorID,
			3                       AS TextFontID	 					
   UNION ALL

 

-- GROUP [11]  -> Temperature 온도
	SELECT
			'ProdLayout'          AS LayoutID,
			1                       AS PageNo,
			11                      AS GroupID,
			1                       AS ID,
			'Temperature'           AS ItemID,
			'미반영'                 AS ItemValue,
			1                       AS TextColorID,
			2                       AS TextFontID	
 UNION ALL

 -- GROUP [13]  -> 월기준 정보
SELECT 'ProdLayout'                                         AS LayoutID,
		  1                                                       AS PageNo,
		  6                                                        AS GroupID,
		  1                                                        AS ID,
		  'SUM'                                            AS ItemID,
		  CONVERT(VARCHAR,   KT.ProdQty2) + ' 개'  AS ItemValue,
	   	--'111155' AS ItemValue,
		  1                     AS TextColorID,
		  2                     AS TextFontID	
FROM	 @MonData KT
UNION ALL

	SELECT
			'ProdLayout'   AS LayoutID,
			1                AS PageNo,
			6               AS GroupID,
			2                AS ID,
			'SUM'           AS ItemID,			
			CONVERT(VARCHAR,   KT.DefectQty2) + ' 개'   AS ItemValue,
			--	'55' AS ItemValue,
			1                AS TextColorID,
			2                AS TextFontID	
	FROM		@MonData KT

---- GROUP [12]  -> Goal  목표값
--	SELECT
--			'ProdLayout'        AS LayoutID,
--			1                     AS PageNo,
--			12                   AS GroupID,
--			1                    AS ID,
--			'Goal'               AS ItemID,
--			--CONVERT(VARCHAR(19),   DT.PlanQty) + ' 개'   AS ItemValue,
--			'100 %'               AS  ItemValue,
--			1                     AS TextColorID,
--			2                     AS TextFontID	
--	FROM		@Data DT
-- UNION ALL

--	SELECT
--			'ProdLayout'   AS LayoutID,
--			1                AS PageNo,
--			12               AS GroupID,
--			2                AS ID,
--			'Goal'           AS ItemID,			
			
--			--CONVERT(VARCHAR(19),   DT.PlanQty) + ' 개'   AS ItemValue,
--			'99 %'        AS ItemValue,
--			1                AS TextColorID,
--			2                AS TextFontID	
--	FROM		@Data DT

	 --UNION ALL

 








--- [중요부분] End ------------------------------------------------------------------

END


