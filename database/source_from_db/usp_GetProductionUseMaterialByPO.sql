-- =============================================
-- Author:		Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Browsable : true
-- Group : 생산관리
-- Create date: 2018-08-27
-- Description:	PO별 사용자재이력
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetProductionUseMaterialByPO]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pPONo VARCHAR(20) = NULL,
	@pMaterialDocType VARCHAR(20) = NULL,
	@pMaterialDocTypeCode VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
	DECLARE @PONo VARCHAR(20) = @pPONo
	DECLARE @MaterialDocTypeCode VARCHAR(20) = CASE WHEN ISNULL(@pMaterialDocTypeCode,'') = '' THEN '%' ELSE @pMaterialDocTypeCode END
	DECLARE @MaterialDocType VARCHAR(20) = CASE WHEN ISNULL(@pMaterialDocType,'') = '' THEN '%' ELSE @pMaterialDocType END

	SELECT
			MDI.PONo,
			MDI.MaterialDocType,
			DT.DocTypeName,
			MDI.MaterialDocTypeCode,
			MDT.MaterialDocTypeName,
			MDI.DocStatus,
			DS.DocStatusName,
			MM.ProductGroupCode,
			PG.ProductGroupName,
			MDD.MaterialCode,
			MM.MaterialName,
			SUM(MDD.RequestQty) AS RequestQty,
			SUM(MDD.AllowQty) AS AllowQty,
			SUM(MDD.ProcessFixQty) AS ProcessFixQty
			--MDLI.LotID,
			--MDLI.LotNo,
			--MDLI.StockQty
	FROM
			STB_MaterialDocInfo MDI WITH(NOLOCK)
			INNER JOIN STB_MaterialDocDetail MDD WITH(NOLOCK)
				ON MDD.MaterialDocNo = MDI.MaterialDocNo
			--LEFT OUTER JOIN STB_MaterialDocLotInfo MDLI WITH(NOLOCK)
			--	ON MDLI.MaterialDocNo = MDI.MaterialDocNo AND
			--	MDLI.MaterialDocDetailNo = MDD.MaterialDocDetailNo
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)
				ON MM.MaterialCode = MDD.MaterialCode
			LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)
				ON PG.ProductGroupCode = MM.ProductGroupCode
			LEFT OUTER JOIN STB_MaterialDocType MDT WITH(NOLOCK)
				ON MDT.MaterialDocTypeCode = MDI.MaterialDocTypeCode
			LEFT OUTER JOIN VW_DocType DT
				ON DT.DocType = MDI.MaterialDocType
			LEFT OUTER JOIN VW_DocStatus DS
				ON DS.DocType = MDI.MaterialDocType AND
				DS.DocStatus = MDI.DocStatus
	WHERE
			MDI.MaterialDocType LIKE @MaterialDocType AND
			MDI.MaterialDocTypeCode LIKE @MaterialDocTypeCode AND
			MDI.PONo = @PONo AND
			MDI.IsCancel = 0
	GROUP BY
			MDI.PONo,
			MDI.MaterialDocType,
			DT.DocTypeName,
			MDI.MaterialDocTypeCode,
			MDT.MaterialDocTypeName,
			MDI.DocStatus,
			DS.DocStatusName,
			MM.ProductGroupCode,
			PG.ProductGroupName,
			MDD.MaterialCode,
			MM.MaterialName
END
