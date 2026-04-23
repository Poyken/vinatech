

-- =============================================
-- Author:		Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-06-01
-- Browsable : true
-- Group : 현장용
-- Description:	바코드를 스캔하여 PORouting된 공정리스트를 가져옵니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetRouteForProductionOrder_SmartApp]
	@pBarcode VARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Barcode VARCHAR(50) = @pBarcode

	SELECT
			SI.Barcode,
			SI.ProdQty,
			SI.MaterialCode,
			MM.MaterialName,
			POR.RouteCode,
			RI.RouteName
	FROM
			STB_SetInfo SI WITH(NOLOCK)
			LEFT OUTER JOIN STB_ProductionOrderRouting POR WITH(NOLOCK)
				ON POR.PONo = SI.PONo
			LEFT OUTER JOIN STB_RouteInfo RI WITH(NOLOCK)
				ON RI.RouteCode = POR.RouteCode
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)
				ON MM.MaterialCode = SI.MaterialCode
	WHERE
			SI.Barcode = @Barcode
	ORDER BY
			POR.RouteIndex
END
