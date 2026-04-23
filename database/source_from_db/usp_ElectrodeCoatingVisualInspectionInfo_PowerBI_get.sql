-- =============================================
-- Author: Kangs (kilee@vina.co.kr)
-- Create date: 2019-01-24
-- Browsable : true
-- Group : PowerBI
-- Description:	전극코팅정보
-- usp_ElectrodeCoatingVisualInspectionInfo_PowerBI_get  '2020-10-19','2020-10-19'                     -- 33개
-- =============================================
CREATE PROCEDURE [dbo].[usp_ElectrodeCoatingVisualInspectionInfo_PowerBI_get]	
					  -- @pCompanyCode VARCHAR(20) = NULL,  -- 사업장 코드 추가 (2020.10.15),
					   @pFromDate Date,
					   @pToDate Date
AS

BEGIN

	DECLARE @FromDate DATE = @pFromDate
	DECLARE @ToDate     DATE = @pToDate
	
	IF @FromDate = '1900-01-01' OR @ToDate = '1900-01-01' BEGIN
		SET @FromDate = dbo.fnGetAggregationPeriod(1)
		SET @ToDate = dbo.fnGetAggregationPeriod(2)
	END

	;WITH DefaultList AS (
		SELECT 'O' AS SideCode, 'FIRST' AS MeasureTimeCode, 1 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
		UNION ALL
		SELECT 'O' AS SideCode, 'FIRST' AS MeasureTimeCode, 2 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
		UNION ALL
		SELECT 'O' AS SideCode, 'FIRST' AS MeasureTimeCode, 3 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
		UNION ALL
		SELECT 'O' AS SideCode, 'MIDDLE' AS MeasureTimeCode, 1 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
		UNION ALL
		SELECT 'O' AS SideCode, 'MIDDLE' AS MeasureTimeCode, 2 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
		UNION ALL
		SELECT 'O' AS SideCode, 'MIDDLE' AS MeasureTimeCode, 3 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
		UNION ALL
		SELECT 'O' AS SideCode, 'LAST' AS MeasureTimeCode, 1 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
		UNION ALL
		SELECT 'O' AS SideCode, 'LAST' AS MeasureTimeCode, 2 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
		UNION ALL
		SELECT 'O' AS SideCode, 'LAST' AS MeasureTimeCode, 3 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
		UNION ALL
		SELECT 'B' AS SideCode, 'FIRST' AS MeasureTimeCode, 1 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
		UNION ALL
		SELECT 'B' AS SideCode, 'FIRST' AS MeasureTimeCode, 2 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
		UNION ALL
		SELECT 'B' AS SideCode, 'FIRST' AS MeasureTimeCode, 3 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
		UNION ALL
		SELECT 'B' AS SideCode, 'MIDDLE' AS MeasureTimeCode, 1 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
		UNION ALL
		SELECT 'B' AS SideCode, 'MIDDLE' AS MeasureTimeCode, 2 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
		UNION ALL
		SELECT 'B' AS SideCode, 'MIDDLE' AS MeasureTimeCode, 3 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
		UNION ALL
		SELECT 'B' AS SideCode, 'LAST' AS MeasureTimeCode, 1 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
		UNION ALL
		SELECT 'B' AS SideCode, 'LAST' AS MeasureTimeCode, 2 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
		UNION ALL
		SELECT 'B' AS SideCode, 'LAST' AS MeasureTimeCode, 3 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
	)
	SELECT  SDP.CompanyCode AS CompanyCode   
	        , ISNULL(ECVII.ElectrodeLotNumber, SI.Barcode) AS ElectrodeLotNumber
			,ISNULL(ECVII.SideCode, DL.SideCode) AS SideCode
			,BC2.Description AS SideCodeName
			,ISNULL(ECVII.MeasureTimeCode, DL.MeasureTimeCode) AS MeasureTimeCode
			,BC.Description AS MeasureTimeCodeName
			,ISNULL(ECVII.Seq, DL.Seq) AS Seq
			,ECVII.LeftValue
			,ECVII.MiddleValue
			,ECVII.RightValue
			,ECVII.CreateDateTime
			,ECVII.CreateUserID
			,ECVII.ChangeDateTime
			,ECVII.ChangeUserID			

		   ,CONVERT(VARCHAR(10), ECI.WorkDate, 121) as 코팅_WorkDate 
		   , SI.MaterialCode       as 품목코드             
			, MM2.MaterialName as 품목명
			, IsNull(EC.Batches, 0) as 배치수


			-- 2020.10.20 추가
			--,EC.OneSide      as 단면
			--,EC.BothSide     as 양면
			--,EC.OneSideLowerTolerance as 단면하위공차
			--,EC.OneSideUpperTolerance as 단면상위공차
			--,EC.BothSideLowerTolerance as 양면하위공차
			--,EC.BothSideUpperTolerance as 양면상위공차

			, EC.OneSide + EC.OneSideLowerTolerance as 단면하한
			, EC.OneSide + EC.OneSideUpperTolerance as 단면상한
			, EC.BothSide + EC.BothSideLowerTolerance as 양면하한
			, EC.BothSide + EC.BothSideUpperTolerance as 양면상한

			--,EC.ProdConThickStdMin as 생산조건_두께규격하한
			--,EC.ProdConThickStdMax as 생산조건_두께규격상한

	  FROM STB_SetInfo SI
	  LEFT OUTER JOIN DefaultList DL	    ON 1=1
	  LEFT OUTER JOIN STB_ElectrodeCoatingVisualInspectionInfo ECVII	    ON SI.Barcode = ECVII.ElectrodeLotNumber	   AND DL.SideCode = ECVII.SideCode	   AND DL.MeasureTimeCode = ECVII.MeasureTimeCode	   AND DL.Seq = ECVII.Seq
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC    	            ON BC.CodeGroup = 'MeasureTime'    	           AND ISNULL(ECVII.MeasureTimeCode, DL.MeasureTimeCode) = BC.ItemCode
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC2  	            ON ISNULL(ECVII.SideCode, DL.SideCode) = BC2.ItemCode	   AND BC2.CodeGroup = 'SideCode'
	   
	  LEFT OUTER JOIN STB_ElectrodeCoatingInfo ECI	          ON SI.Barcode = ECI.ElectrodeLotNumber  AND   ECVII.ElectrodeLotNumber =  ECI.ElectrodeLotNumber     -- 2. 전극코팅정보 
	  LEFT OUTER JOIN STB_MaterialMaster MM2			ON SI.MaterialCode = MM2.MaterialCode

	    LEFT OUTER JOIN STB_ElectrodeCommon EC        ON EC.ProdCode = SI.MaterialCode                      -- 배치수 컬럼때문에 Join
		 LEFT OUTER JOIN STB_DayProdPlan SDP	        ON SDP.DayPlanNo = SI.DayPlanNo
	 WHERE 1=1
	
	 --and SI.Barcode = @ElectrodeLotNumber
	--  AND CONVERT(DATE, ECVII.CreateDateTime)      BETWEEN @FromDate And @ToDate  --원본백업
	  and  CONVERT(VARCHAR(10), ECI.WorkDate, 121)  BETWEEN @FromDate And @ToDate 
	  -- AND ((@CompanyCode = '*') OR ( SDP.CompanyCode = @CompanyCode))

	 ORDER BY CASE WHEN DL.SideCode = 'O' THEN 1
	                      WHEN DL.SideCode = 'B' THEN 2	   ELSE DL.SideCode END
		     ,CASE WHEN DL.MeasureTimeCode = 'FIRST' THEN 1
			       WHEN DL.MeasureTimeCode = 'MIDDLE' THEN 2
				   WHEN DL.MeasureTimeCode = 'LAST' THEN 3	   ELSE 4 END
		     ,DL.Seq
END