-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2019-01-24
-- Browsable : true
-- Group : PowerBI > 전극롤프레싱정보
-- Description:	전극롤프레싱외관검사정보

-- usp_ElectrodeRollPressingVisualInspectionInfo_PowerBI_get  '2022-01-01','2022-02-01'
-- =====================================================================
CREATE PROCEDURE [dbo].[usp_ElectrodeRollPressingVisualInspectionInfo_PowerBI_get]
	--@pCompanyCode VARCHAR(20) = NULL,  -- 사업장 코드 추가 (2020.10.15),
	--@pElectrodeLotNumber VARCHAR(20) = NULL
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
		SELECT 'FIRST' AS MeasureTimeCode, 1 AS Seq UNION ALL
		SELECT 'FIRST' AS MeasureTimeCode, 2 AS Seq UNION ALL
		SELECT 'FIRST' AS MeasureTimeCode, 3 AS Seq UNION ALL
		SELECT 'MIDDLE' AS MeasureTimeCode, 1 AS Seq UNION ALL
		SELECT 'MIDDLE' AS MeasureTimeCode, 2 AS Seq UNION ALL
		SELECT 'MIDDLE' AS MeasureTimeCode, 3 AS Seq UNION ALL
		SELECT 'LAST' AS MeasureTimeCode, 1 AS Seq UNION ALL
		SELECT 'LAST' AS MeasureTimeCode, 2 AS Seq UNION ALL
		SELECT 'LAST' AS MeasureTimeCode, 3 AS Seq
	)
	SELECT   SDP.CompanyCode AS CompanyCode
	        ,  ISNULL(ERPVII.ElectrodeLotNumber, SI.Barcode) AS ElectrodeLotNumber
			,ISNULL(ERPVII.MeasureTimeCode, DL.MeasureTimeCode) AS MeasureTimeCode
			,BC.Description AS MeasureTimeCodeName
			,ISNULL(ERPVII.Seq, DL.Seq) AS Seq
			,ERPVII.LeftValue
			,ERPVII.MiddleValue
			,ERPVII.RightValue
			,ERPVII.CreateDateTime
			,ERPVII.CreateUserID
			,ERPVII.ChangeDateTime
			,ERPVII.ChangeUserID

			,CONVERT(VARCHAR(10), ERPI.WorkDate, 121) as 롤프레싱_WorkDate
			, SI.MaterialCode       as 품목코드             
			, MM2.MaterialName as 품목명
			, IsNull(EC.Batches, 0) as 배치수

			-- 2020.10.20 추가
			,EC.OneSide      as 단면
			,EC.BothSide     as 양면

			--,EC.OneSideLowerTolerance as 단면하위공차
			--,EC.OneSideUpperTolerance as 단면상위공차
			--,EC.BothSideLowerTolerance as 양면하위공차
			--,EC.BothSideUpperTolerance as 양면상위공차
			--, EC.OneSide + EC.OneSideLowerTolerance as 단면하한
			--, EC.OneSide + EC.OneSideUpperTolerance as 단면상한
			--, EC.BothSide + EC.BothSideLowerTolerance as 양면하한
			--, EC.BothSide + EC.BothSideUpperTolerance as 양면상한

			,EC.ProdConThickStdMin as 생산조건_두께규격하한
			,EC.ProdConThickStdMax as 생산조건_두께규격상한

	  FROM STB_SetInfo SI
	  LEFT OUTER JOIN DefaultList DL	    ON 1 = 1
	  LEFT OUTER JOIN STB_ElectrodeRollPressingVisualInspectionInfo ERPVII	    ON SI.Barcode = ERPVII.ElectrodeLotNumber	   AND DL.MeasureTimeCode = ERPVII.MeasureTimeCode	   AND DL.Seq = ERPVII.Seq
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC	                    ON BC.ItemCode = DL.MeasureTimeCode

	   LEFT OUTER JOIN STB_ElectrodeRollPressingInfo ERPI	  ON SI.Barcode = ERPI.ElectrodeLotNumber  AND   ERPVII.ElectrodeLotNumber =  ERPI.ElectrodeLotNumber   -- 3. 전극롤프레싱정보
	   LEFT OUTER JOIN STB_MaterialMaster MM2			ON SI.MaterialCode = MM2.MaterialCode

	    LEFT OUTER JOIN STB_ElectrodeCommon EC        ON EC.ProdCode = SI.MaterialCode                      -- 배치수 컬럼때문에 Join
		LEFT OUTER JOIN STB_DayProdPlan SDP	        ON SDP.DayPlanNo = SI.DayPlanNo
	 WHERE 1=1
	  -- AND SI.Barcode = @ElectrodeLotNumber   -- 주석부분임!!
	  -- AND CONVERT(DATE, ERPVII.CreateDateTime)      BETWEEN @FromDate And @ToDate        -- 원본백업
         AND CONVERT(VARCHAR(10), ERPI.WorkDate, 121)      BETWEEN @FromDate And @ToDate		  		-- WorkDate로 변경
	  -- AND ((@CompanyCode = '*') OR ( SDP.CompanyCode = @CompanyCode))

	 ORDER BY CASE WHEN DL.MeasureTimeCode = 'FIRST' THEN 1
	               WHEN DL.MeasureTimeCode = 'MIDDLE' THEN 2
				   WHEN DL.MeasureTimeCode = 'LAST' THEN 3
				   ELSE 4 END
		     ,DL.Seq
END