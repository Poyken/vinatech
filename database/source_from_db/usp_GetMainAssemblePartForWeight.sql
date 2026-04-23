-- =============================================
-- Author:		Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-16
-- Group : 생산관리
-- Description:	생산시 사용원자재를 가져옵니다
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetMainAssemblePartForWeight]
	@pProcessLanguage VARCHAR(20),
	@pProcessUserID VARCHAR(20),
	@pControlNo VARCHAR(20) = NULL
WITH RECOMPILE
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @ControlNo VARCHAR(20) = @pControlNo

	SELECT
			SI.ControlNo,
			SI.Barcode,
			MM.ProductGroupCode,
			PG.ProductGroupName,
			POB.ChildMaterialCode AS AsmPartCode,
			MM.MaterialName AS AsmPartName,
			ISNULL(MAPW.AsmQty,0) AS AsmQty
	FROM
			STB_SetInfo SI WITH(NOLOCK)
			LEFT OUTER JOIN STB_ProductionOrderBom POB WITH(NOLOCK)
				ON POB.PONo = SI.PONo AND
				POB.MaterialCode = SI.MaterialCode AND
				POB.IsUseProduction = 1
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)
				ON MM.MaterialCode = POB.ChildMaterialCode
			LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)
				ON PG.ProductGroupCode = MM.ProductGroupCode
			LEFT OUTER JOIN STB_MainAssemblePartWeight MAPW WITH(NOLOCK)
				ON MAPW.ControlNo = SI.ControlNo AND
				MAPW.AsmPartCode = POB.ChildMaterialCode
	WHERE
			SI.ControlNo = @ControlNo
END
