-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2019-01-24
-- Browsable : true
-- Group : PowerBI
-- Description:	1.믹싱혼합단계정보
-- 2020.10.16 배치수컬럼추가

-- 프로그램 실행 :   usp_ElectrodeMixStepInfo_PowerBI_get 'VVT', '2020-10-14','2020-10-30'
-- ================================================================================================
CREATE PROCEDURE [dbo].[usp_ElectrodeMixStepInfo_PowerBI_get]	
					@pFromDate Date,
					@pToDate Date

AS
BEGIN
	DECLARE @FromDate DATE = @pFromDate
	DECLARE @ToDate   DATE = @pToDate

	IF @FromDate = '1900-01-01' OR @ToDate = '1900-01-01' BEGIN
		SET @FromDate = dbo.fnGetAggregationPeriod(1)
		SET @ToDate = dbo.fnGetAggregationPeriod(2)
	END


	SELECT   SDP.CompanyCode AS CompanyCode	
	         , ISNULL(EMSI.ElectrodeLotNumber, SI.Barcode) AS ElectrodeLotNumber
			,ISNULL(EMSI.ElectrodeStep, ES.ElectrodeStepCode) AS ElectrodeStep
			,ISNULL(EMSI.Seq, ES.Seq) AS Seq
			,ISNULL(EMSI.ElectrodeMaterialCode, ES.MaterialCode) AS ElectrodeMaterialCode
			,MM.MaterialName AS ElectrodeMaterialName
			,EMSI.InputQty1
			,EMSI.InputQty2
			,EMSI.MaterialLotNumber
			,EMSI.BinderInputTime
			,EMSI.BinderOutputTime
			,EMSI.MixingInputTime
			,EMSI.MixingOutputTime
			,EMSI.SpecInOut
			,EMSI.SpecOutQty
			,EMSI.CreateDateTime
			, CONVERT(DATE, EMSI.CreateDateTime)  as Date
			,EMSI.CreateUserID
			,EMSI.ChangeDateTime
			,EMSI.ChangeUserID

			, CONVERT(VARCHAR(10), EM.WorkDate, 121) as 믹싱_WorkDate
			,  SI.MaterialCode       as 품목코드             
			, MM.MaterialName as 품목명
			, IsNull(EC.Batches, 0) as 배치수
			 ,ES.StdMinVal as 최소기준량
		   ,ES.StdMaxVal as 최대기준량
	  FROM STB_ElectrodeStep ES 
			 INNER JOIN STB_SetInfo SI	                               ON ES.ProdCode = SI.MaterialCode
			 LEFT OUTER JOIN STB_ElectrodeMixStepInfo EMSI ON SI.Barcode = EMSI.ElectrodeLotNumber	   AND EMSI.ElectrodeStep = ES.ElectrodeStepCode	   AND EMSI.Seq = ES.Seq
			 LEFT OUTER JOIN STB_MaterialMaster MM	       ON MM.MaterialCode = ISNULL(EMSI.ElectrodeMaterialCode, ES.MaterialCode)

			  LEFT OUTER JOIN STB_ElectrodeMixInfo EM		ON SI.Barcode = EM.ElectrodeLotNumber           -- 1. 전극믹싱정보  (추가-주영진)			 
			  LEFT OUTER JOIN STB_ElectrodeCommon EC    ON EC.ProdCode = ES.ProdCode                      -- 배치수 컬럼때문에 Join
			  LEFT OUTER JOIN STB_DayProdPlan SDP	        ON SDP.DayPlanNo = SI.DayPlanNo
	 WHERE 1=1
	   --AND SI.Barcode = 'VJKS0420001E01'	     -- 주석부분!!!
		-- AND  CONVERT(DATE, EMSI.CreateDateTime)  BETWEEN @FromDate And @ToDate  --원본백업
		 AND CONVERT(VARCHAR(10), EM.WorkDate, 121)  BETWEEN @FromDate And @ToDate  
		--  AND ((@CompanyCode = '*') OR ( SDP.CompanyCode = @CompanyCode))


	 ORDER BY CASE WHEN ES.ElectrodeStepCode = 'D'  THEN 1
	               WHEN ES.ElectrodeStepCode = 'G'  THEN 2
				   WHEN ES.ElectrodeStepCode = 'K'  THEN 3
				   WHEN ES.ElectrodeStepCode = 'S'  THEN 4
				   WHEN ES.ElectrodeStepCode = 'S1'  THEN 4.1 --Mr.Tung add to fix error convert Varchar to INT
				   WHEN ES.ElectrodeStepCode = 'S2'  THEN 4.2 --Mr.Tung add to fix error convert Varchar to INT
				   WHEN ES.ElectrodeStepCode = 'DA' THEN 5
				   ELSE 10 END
			,ES.Seq

END

-- select * from STB_ElectrodeMixStepInfo