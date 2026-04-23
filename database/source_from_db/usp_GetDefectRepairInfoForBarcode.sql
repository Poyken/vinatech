-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-23
-- Browsable : true
-- Group : 품질관리
-- Description:	바코드의 등록된 불량정보를 가져옵니다
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetDefectRepairInfoForBarcode]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pLineCode VARCHAR(20) = NULL,
	@pRouteCode VARCHAR(20) = NULL,
	@pBarcode VARCHAR(50) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @LineCode VARCHAR(20) = @pLineCode
	DECLARE @RouteCode VARCHAR(20) = @pRouteCode
	DECLARE @Barcode VARCHAR(50) = @pBarcode

	SELECT
			@LineCode AS LineCode,
			@RouteCode AS RouteCode,
			SI.PONo,
			SI.DayPlanNo,
			SI.MaterialCode,
			MM.MaterialName,
			SI.Barcode AS Barcode,
			DI.DefectGroupCode,
			DG.BasicDefectGroupName,
			DI.DefectCode,
			DI.BasicDefectName,
			ISNULL(SUM(DRI.DefectQty),0) AS CurrentDefectQty,
			0 AS DefectQty
	FROM
			STB_SetInfo SI WITH(NOLOCK)
			LEFT OUTER JOIN STB_DefectRepairInfo DRI WITH(NOLOCK)
				ON DRI.ControlNo = SI.ControlNo AND
				DRI.FindLineCode = @LineCode AND
				DRI.FindRouteCode = @RouteCode
			LEFT OUTER JOIN STB_DefectInfo DI WITH(NOLOCK)
			  ON DRI.DefectCode = DI.DefectCode
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)
					ON MM.MaterialCode = SI.MaterialCode
			LEFT OUTER JOIN STB_DefectGroup DG WITH(NOLOCK)
				ON DG.DefectGroupCode = DI.DefectGroupCode
			
	WHERE
			SI.Barcode = @Barcode
	GROUP BY
			SI.PONo,
			SI.DayPlanNo,
			SI.MaterialCode,
			MM.MaterialName,
			SI.Barcode,
			DI.DefectGroupCode,
			DG.BasicDefectGroupName,
			DI.DefectCode,
			DI.BasicDefectName
END
