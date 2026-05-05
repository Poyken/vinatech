


-- =============================================
-- Author:	    Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2016-07-16
-- Browsable : true
-- Group : 재고관리 > [G650] 제품재고실사 > 하단 Grid 재고실사 기준정보 조회용
-- Description:	재고실사 기준데이터를 조회합니다.
-- Modified:
--               2020.07.14 순번정렬
-- [프로시저실행문]   exec usp_StocktakingPlanResult_get '','','20200714000007'                      -- StocktakingDocNo : 실사번호 
-- =============================================
Create PROCEDURE [dbo].[usp_StocktakingPlanResult_get_20200723]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pStocktakingDocNo VARCHAR(20) = NULL

AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @StocktakingDocNo VARCHAR(20) = @pStocktakingDocNo

    
	SELECT
			SPR.StocktakingDocNo AS OldStocktakingDocNo,
		--  IsNull(SPR.SDNSeqNo, 0) AS OldSDNSeqNo,                    -- 2020.07.14 추가
			SPR.SDNSeqNo AS OldSDNSeqNo,                    
			SPR.StocktakingDocNo,
			SPR.SDNSeqNo,
			SPR.MaterialLocationCode,
			OML.MaterialLocationName,
			SPR.MaterialLotNo,
			SPR.LotID,
			SPR.MaterialCode,
			MM.MaterialName,
			MM.AltMaterialCode,
			MM.MaterialTypeCode,
			MT.MaterialTypeName,
			MM.ProductGroupCode,
			PG.ProductGroupName,
			MM.MaterialUnit,
			SPR.MaterialStockAttribute,
			SPR.StockAttrib1,
			SPR.StockAttrib2,
			SPR.StockAttrib3,
			SPR.PackingID,                               -- 패킹아이디 (원본)
			--Case When MLL.PackingID = '' Then MLI.PackingID ELSE MLL.PackingID END AS PackingID ,                                 -- 2020.07.14 수정 (kilee)			
			--Case When SPR.PackingID = '' Then MLI.PackingID 
			--       When MLL.PackingID = '' Then SPR.PackingID 
			--	   When MLI.PackingID = '' Then MLL.PackingID 
			--ELSE SPR.PackingID END AS PackingID ,                                 -- 2020.07.14 수정 (kilee)			
			SPR.BasicQty,
			--MLI.LotNo,
			SPR.LotAttr01,
			SPR.LotAttr02,
			SPR.LotAttr03,
			SPR.LotAttr04,
			SPR.LotAttr05,
			SPR.LotAttr06,
			SPR.LotAttr07,
			SPR.LotAttr08,
			SPR.LotAttr09,
			SPR.LotAttr10,
			SPR.IsStocktaking,
			SPR.StocktakingQty,
			SPR.StocktakingMaterialLocationCode,
			SML.MaterialLocationName AS StocktakingMaterialLocationName,
			SPR.StocktakingUserID,
			SPR.StocktakingDateTime,
			SPR.IsApplied,
			SPR.CreateDateTime,
			SPR.CreateUserID,
			SPR.ChangeDateTime,
			SPR.ChangeUserID
			--MLL.MaterialDocNo
	FROM
			                        STB_StocktakingPlanResult SPR WITH(NOLOCK)
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)			ON	MM.MaterialCode = SPR.MaterialCode
			LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK)				ON	MT.MaterialTypeCode = MM.MaterialTypeCode
			LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)				ON	PG.ProductGroupCode = MM.ProductGroupCode
			LEFT OUTER JOIN STB_MaterialLocation OML WITH(NOLOCK)			ON	OML.MaterialLocationCode = SPR.MaterialLocationCode
			LEFT OUTER JOIN STB_MaterialLocation SML WITH(NOLOCK)			ON	SML.MaterialLocationCode = SPR.StocktakingMaterialLocationCode
			--LEFT OUTER JOIN STB_MaterialLotInfo MLI WITH (NOLOCK)			ON (MLI.MaterialLotNo = SPR.MaterialLotNo)  OR (MLI.LotID = SPR.LotID)      --OR문 추가
			--LEFT OUTER JOIN STB_MaterialDocLotInfo MLL WITH (NOLOCK)		ON (MLL.LotID = MLI.LotID)  OR  (MLL.LotID = SPR.LotID)                             --OR문 추가
	WHERE
			SPR.StocktakingDocNo = @StocktakingDocNo
 
     Order by SPR.SDNSeqNo ASC                                   --2020.07.14 추가
			 
END