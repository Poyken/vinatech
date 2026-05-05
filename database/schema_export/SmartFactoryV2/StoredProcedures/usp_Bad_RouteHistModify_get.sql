-- Procedure: usp_Bad_RouteHistModify_get
-- =============================================
-- Author : Kangs (kilee@vina.co.kr)
-- Create Date : 2022-04-04
-- Browsable : True
-- Group : 생산관리 > 생산실적 수정 > 2번째 불량현황 조회용
-- Description :	
-- Modified : 
-- 2022-04-04 파라미터값 수정

-- 프로시저 실행 :   usp_Bad_RouteHistModify_get   'kilee2',    'Korean',   'VJJQ302R750670', 'E-22'
-- ===============================================================================
                                        
CREATE PROCEDURE [dbo].[usp_Bad_RouteHistModify_get]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pBarcode VARCHAR(50) = NULL,
						@pRouteCode VARCHAR(50) = NULL
AS

BEGIN
	SET NOCOUNT ON;

	DECLARE @Barcode    VARCHAR(50) = @pBarcode
	DECLARE @ControlNo  VARCHAR(20) 
	DECLARE @RouteCode VARCHAR(20)  = @pRouteCode     


 -- ControlNo 을 알아내기 위한 용도
    SELECT @ControlNo = SI.ControlNo 
	 FROM  STB_SetInfo SI WITH(NOLOCK)			
    WHERE 1=1		
		AND SI.Barcode = @Barcode		


	 Select SDR.DefectSummaryNo
	        , SDR.PONo
			, SDR.DayPlanNo
			, SDR.FindJobDate
			, SDR.FindRouteCode As RouteCode
			, RI.RouteName As RouteName
			, LI.LineName
			, SDR.MaterialCode
			, SMM.MaterialName
			, Isnull(SDR.DefectQty, 0) As DefectQty
			, SDR.CreateUserID 
			, SDR.DefectCode As DefectCode
			, DI.BasicDefectName
		From  STB_DefectRepairInfo SDR
				Left Outer Join STB_MaterialMaster SMM   WITH(NOLOCK) On SMM.MaterialCode = SDR.MaterialCode
				Left Outer Join STB_LineInfo LI                WITH(NOLOCK) On LI.LineCode = SDR.FindLineCode
				Left Outer Join STB_RouteInfo RI WITH(NOLOCK)			 On RI.RouteCode = SDR.FindRouteCode
				Left Outer Join STB_DefectInfo DI WITH(NOLOCK)            On DI.DefectCode = SDR.DefectCode
		 Where 1=1
		   And SDR.ControlNo = @ControlNo
		   And SDR.FindRouteCode LIKE @RouteCode 	   



	--SELECT
	--		PRH.PONo,
	--		PRH.DayPlanNo,
	--		--PRH.ControlNo,
	--		--SI.Barcode,
	--		PRH.MaterialCode,
	--		MM.MaterialName,
	--		PRH.BomVersion,
	--		PRH.JobDate,
	--		PRH.ShiftCode,
	--		SC.Shift,
	--		PRH.TimeCode,
	--		PRH.LineCode,
	--		LI.LineName,
	--		--POR.RouteIndex,
	--		PRH.RouteCode,
	--		RI.RouteName,
	--		PRH.WorkerCode,
	--		PWI.WorkerName
	--		--CASE WHEN DI.DefectQty < 0 THEN   PRH.ProdQty   ELSE  PRH.ProdQty - ISNULL(DI.DefectQty, 0)  END   AS ProdQty,                     -- 2019.09.04 마이너스수량 처리 수정 (kilee)
	--		--PRH.ProdDateTime
	--FROM
	--		STB_ProdRouteHist PRH WITH(NOLOCK)
	--		LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)		ON MM.MaterialCode = PRH.MaterialCode
	--		LEFT OUTER JOIN STB_LineInfo LI WITH(NOLOCK)				    ON LI.LineCode = PRH.LineCode
	--		LEFT OUTER JOIN STB_RouteInfo RI WITH(NOLOCK)				ON RI.RouteCode = PRH.RouteCode
	--		LEFT OUTER JOIN STB_ProdWorkerInfo PWI WITH(NOLOCK)	ON PWI.WorkerCode = PRH.WorkerCode
	--		LEFT OUTER JOIN STB_SetInfo SI WITH(NOLOCK)				    ON SI.ControlNo = PRH.ControlNo
	--		LEFT OUTER JOIN STB_ProductionOrderRouting POR WITH(NOLOCK)		ON POR.PONo = PRH.PONo            AND POR.RouteCode = PRH.RouteCode
	--		LEFT OUTER JOIN VW_ShiftCode SC				                                ON SC.ShiftCode = PRH.ShiftCode
	--		--LEFT OUTER JOIN DefectInfo DI				                                    ON PRH.ControlNo = DI.ControlNo	  AND PRH.RouteCode = DI.FindRouteCode            --- 앞에서 만든 TABLE
	--WHERE 1=1
	--		--AND PRH.LineCode LIKE @LineCode 
	--		--AND PRH.RouteCode LIKE @RouteCode 
	--		--AND PRH.PONo = @PONo 		 
	--		--AND PRH.DayPlanNo LIKE @DayPlanNo 
	--		AND PRH.ControlNo LIKE @ControlNo 
	--	    --AND (SI.Barcode = @Barcode OR SI.Barcode = (SELECT NewBarcode   FROM STB_LotChangeMaterialHistory  WHERE OldBarcode = @Barcode))
	--ORDER BY
	--		POR.RouteIndex
	--	  ,	PRH.ProdRouteHistNo DESC


END
GO

