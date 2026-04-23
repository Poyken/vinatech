-- =============================================
-- Author:		Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-09-05
-- Browsable : false
-- Group : 생산관리
-- Description:	원자재 투입이력을 가져옵니다
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetRawMaterialLotForBarcode_VNT]
	@pBarcode VARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @Barcode VARCHAR(50) = @pBarcode

	SELECT
			MM.ProductGroupCode,
			PG.ProductGroupName,
			POB.ChildMaterialCode AS MaterialCode,
			MM.MaterialName,
			MM.MaterialTypeCode,
			MT.MaterialTypeName,
			MAPI.AsmLotNo,
			MAPI.AsmDateTime
	FROM
			STB_ProductionOrderBom POB WITH(NOLOCK)
			LEFT OUTER JOIN STB_SetInfo SI WITH(NOLOCK)
				ON POB.PONo = SI.PONo
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)
				ON MM.MaterialCode = POB.ChildMaterialCode
			LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)
				ON PG.ProductGroupCode = MM.ProductGroupCode
			LEFT OUTER JOIN STB_MainAssemblePartInfo MAPI WITH(NOLOCK)
				ON MAPI.ControlNo = SI.ControlNo AND
				POB.ChildMaterialCode = MAPI.AsmPartCode
			LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK)
				ON MT.MaterialTypeCode = MM.MaterialTypeCode
	WHERE
			SI.Barcode = @Barcode
	UNION ALL
	-- 코팅롤
	SELECT
			DISTINCT
			MM.ProductGroupCode,
			PG.ProductGroupName,				-- 원자재구분
			SI.MaterialCode,					-- 원자재코드
			MM.MaterialName,					-- 원자재명
			MM.MaterialTypeCode,
			MT.MaterialTypeName,
			SI.Barcode,
			SI.CreateDateTime					-- 투입시간
	FROM 
			STB_SetInfo CSI WITH(NOLOCK)
			INNER JOIN STB_SetInfo SI WITH(NOLOCK)
				ON CSI.SIExtText01 = SI.Barcode
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)	
				ON MM.MaterialCode = SI.MaterialCode
			LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)
				ON PG.ProductGroupCode = MM.ProductGroupCode
			LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK)
				ON MT.MaterialTypeCode = MM.MaterialTypeCode
	WHERE
			CSI.Barcode IN (
								SELECT
										DISTINCT
										MAPI.AsmLotNo
								FROM
										STB_SetInfo SI WITH(NOLOCK)
										LEFT OUTER JOIN STB_MainAssemblePartInfo MAPI WITH(NOLOCK)
											ON MAPI.ControlNo = SI.ControlNo
								WHERE
										SI.Barcode = @Barcode
							)
END
