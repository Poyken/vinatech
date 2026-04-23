-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-20
-- Browsable : true
-- Group : 생산관리
-- Description:	
-- Modified: 마이너스수량 개선

-- EXEC usp_ProdRouteHist_get '','','','','190603000003','' ,'20190830000070','',''
--                                                   pono              ControlNo     
-- =============================================
                                        
CREATE PROCEDURE [dbo].[usp_ProdRouteHist_get]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pLineCode VARCHAR(20) = NULL,
						@pRouteCode VARCHAR(20) = NULL,
						@pPONo VARCHAR(20) = NULL,
						@pDayPlanNo VARCHAR(20) = NULL,
						@pControlNo VARCHAR(20) = NULL,
						@pJobDate DATE = NULL,
						@pShiftCode VARCHAR(1) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @LineCode VARCHAR(20) = CASE WHEN ISNULL(@pLineCode,'') = '' THEN '%' ELSE @pLineCode END
	DECLARE @RouteCode VARCHAR(20) = CASE WHEN ISNULL(@pRouteCode,'') = '' THEN '%' ELSE @pRouteCode END
	DECLARE @PONo VARCHAR(20) = @pPONo
	DECLARE @DayPlanNo VARCHAR(20) = CASE WHEN ISNULL(@pDayPlanNo,'') = '' THEN '%' ELSE @pDayPlanNo END
	DECLARE @JobDate DATE = @pJobDate
	DECLARE @ControlNo VARCHAR(20) = CASE WHEN ISNULL(@pControlNo,'') = '' THEN '%' ELSE @pControlNo END
	DECLARE @ShiftCode VARCHAR(20) = CASE WHEN ISNULL(@pShiftCode,'') = '' THEN '%' ELSE @pShiftCode END

	;WITH DefectInfo AS
	(
		SELECT
				DRI.ControlNo,
				DRI.FindRouteCode,
				SUM(DRI.DefectQty) AS DefectQty,
				SUM(DRI.LossQty) AS LossQty
		FROM
				STB_DefectRepairInfo DRI WITH(NOLOCK)
				INNER JOIN STB_SetInfo SI WITH(NOLOCK)					ON SI.ControlNo = DRI.ControlNo
        WHERE DRI.RepairType NOT IN ('MISSING', 'FINISH')
		 -- AND DRI.ControlNo = '20190830000070'                                  -- 주석부분임                            (포장공정 E-28)  -164
		GROUP BY
				DRI.ControlNo, DRI.FindRouteCode      
	)
	

	SELECT
			PRH.PONo,
			PRH.DayPlanNo,
			PRH.ControlNo,
			SI.Barcode,
			PRH.MaterialCode,
			MM.MaterialName,
			PRH.BomVersion,
			PRH.JobDate,
			PRH.ShiftCode,
			SC.Shift,
			PRH.TimeCode,
			PRH.LineCode,
			LI.LineName,
			POR.RouteIndex,
			PRH.RouteCode,
			RI.RouteName,
			PRH.WorkerCode,
			PWI.WorkerName,
		 -- PRH.ProdQty - ISNULL(DI.DefectQty, 0)                                                                                  AS ProdQty,                     -- 2019.09.04 원본백업			
		 --	CASE WHEN DI.DefectQty < 0 THEN   PRH.ProdQty   ELSE  PRH.ProdQty - ISNULL(DI.DefectQty, 0)  END   AS ProdQty,                     -- 2019.09.04 마이너스수량 처리 수정 (kilee)
			PRH.ProdQty,
			PRH.ProdDateTime
	FROM
			STB_ProdRouteHist PRH WITH(NOLOCK)
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)		ON MM.MaterialCode = PRH.MaterialCode
			LEFT OUTER JOIN STB_LineInfo LI WITH(NOLOCK)				    ON LI.LineCode = PRH.LineCode
			LEFT OUTER JOIN STB_RouteInfo RI WITH(NOLOCK)				ON RI.RouteCode = PRH.RouteCode
			LEFT OUTER JOIN STB_ProdWorkerInfo PWI WITH(NOLOCK)	ON PWI.WorkerCode = PRH.WorkerCode
			LEFT OUTER JOIN STB_SetInfo SI WITH(NOLOCK)				    ON SI.ControlNo = PRH.ControlNo
			LEFT OUTER JOIN STB_ProductionOrderRouting POR WITH(NOLOCK)		ON POR.PONo = PRH.PONo            AND POR.RouteCode = PRH.RouteCode
			LEFT OUTER JOIN VW_ShiftCode SC				                                ON SC.ShiftCode = PRH.ShiftCode
			LEFT OUTER JOIN DefectInfo DI				                                    ON PRH.ControlNo = DI.ControlNo	  AND PRH.RouteCode = DI.FindRouteCode            --- 앞에서 만든 TABLE
	WHERE 1=1
			AND PRH.LineCode LIKE @LineCode 
			AND PRH.RouteCode LIKE @RouteCode 
			AND PRH.PONo = @PONo 
		 -- AND PRH.PONo = '190603000003'
			AND PRH.DayPlanNo LIKE @DayPlanNo 
			AND PRH.ControlNo LIKE @ControlNo 
		 -- AND PRH.JobDate = @JobDate 
		 -- AND PRH.ShiftCode LIKE @ShiftCode
	ORDER BY
			POR.RouteIndex
		  ,	PRH.ProdRouteHistNo DESC


END


--  SELECT * FROM STB_ProdRouteHist WHERE PONO = '190603000003' AND CONTROLNO = '20190830000070'