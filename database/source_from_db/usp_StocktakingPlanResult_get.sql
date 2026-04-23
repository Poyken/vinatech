


-- =============================================
-- Author:	    Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2016-07-16
-- Browsable : true
-- Group : 재고관리 > [G650] 제품재고실사 > 재고실사 기준정보
--            자재관리 > [F750]  자재재고실사 > 재고실사 기준정보
-- Description:	재고실사 기준데이터를 조회합니다.
-- Modified:
--               2020.07.14 순번정렬
--               2020.07.23 라벨관련정보 추가
--               2020.11.24 제품재고실사 수정

-- [프로시저실행문]   exec usp_StocktakingPlanResult_get '','','20201005000003'                      -- StocktakingDocNo : 실사번호 
-- [프로시저실행문]   exec usp_StocktakingPlanResult_get '','','20201124000001'                      -- StocktakingDocNo :  제품재고실사번호
-- =============================================

CREATE PROCEDURE [dbo].[usp_StocktakingPlanResult_get]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pStocktakingDocNo VARCHAR(20) = NULL,
						@pLabelType NVARCHAR(30) = NULL                           -- 라벨인쇄로 인한 추가부분
AS

BEGIN
	SET NOCOUNT ON;

	DECLARE @StocktakingDocNo VARCHAR(20)   = @pStocktakingDocNo
	DECLARE @LabelType            NVARCHAR(30) = @pLabelType
    
	-- 라벨인쇄로 인한 추가부분
	;WITH LabelInfo AS
	(
		SELECT
				RANK() OVER (PARTITION BY LI.LabelType,LI.FormatName ORDER BY LI.FormatVersion DESC) AS RankIndex,
				LI.LabelType,
				LI.FormatName,
				LI.CommandType,
				LI.Dpi,
				LI.PrinterName
		FROM
				SmartFramework.dbo.STB_LabelInfo LI WITH(NOLOCK)
		WHERE
				LI.IsApproval = 1 AND
				LI.ApplyDate <= GETDATE()
	)



	SELECT
			SPR.StocktakingDocNo AS OldStocktakingDocNo,
			SPR.SDNSeqNo           AS OldSDNSeqNo,                    
			SPR.StocktakingDocNo,
			SPR.SDNSeqNo,
			SPR.MaterialLocationCode,
			OML.MaterialLocationName,
			SPR.MaterialLotNo,
			SPR.LotID  AS LotID ,			                     --2020.11.19 추가 (제품재고실사부분)
			MLI.LotNo AS LotNumber,                       --2020.08.21추가 (구보겸-자재재고실사부분)
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
			--ELSE SPR.PackingID                   END AS PackingID ,                                 -- 2020.07.14 수정 (kilee)		
				
			SPR.BasicQty,
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
			SPR.ChangeUserID,
			--MLL.MaterialDocNo
			--LI.LabelType,
			'BoxLabel' AS LabelType,
			LI.FormatName,
			LI.CommandType,
			LI.Dpi,
			LI.PrinterName,
			0 AS LabelQty,
			0 AS LotQty,
			-- 포장라벨땜에 추가되는사항
			ISNULL(PLS.LotNo, SPR.LotID)              AS LotNo,                  -- 이게 조립바코드임!
			ISNULL(PLS.Voltage, MBI.MBIExtText04) AS Voltage,
			ISNULL(PLS.Farad, MBI.MBIExtText05)    AS Farad,
			ISNULL(PLS.Rating, '(' + RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2) + RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH)), 2) + ')') AS Rating,
			ISNULL(PLS.PartNo, RTRIM(LTRIM(SUBSTRING(ModelName, CHARINDEX(' ', ModelName), 12))) + CASE WHEN CHARINDEX('-L', ModelName) > 0 THEN '-L' ELSE '' END) AS PartNo,
			CASE WHEN CHARINDEX('-L', ModelName) > 0 THEN '-L' ELSE '' END                                                                                                                                AS PartNo1
	FROM
			                        STB_StocktakingPlanResult SPR WITH(NOLOCK)
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)			ON	MM.MaterialCode = SPR.MaterialCode
			LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK)				ON	MT.MaterialTypeCode = MM.MaterialTypeCode
			LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)				ON	PG.ProductGroupCode = MM.ProductGroupCode
			LEFT OUTER JOIN STB_MaterialLocation OML WITH(NOLOCK)			ON	OML.MaterialLocationCode = SPR.MaterialLocationCode
			LEFT OUTER JOIN STB_MaterialLocation SML WITH(NOLOCK)			ON	SML.MaterialLocationCode = SPR.StocktakingMaterialLocationCode
			LEFT OUTER JOIN STB_MaterialLotInfo MLI WITH (NOLOCK)			ON (MLI.MaterialLotNo = SPR.MaterialLotNo) -- OR (MLI.LotID = SPR.LotID)      --OR문 추가
			--LEFT OUTER JOIN STB_MaterialDocLotInfo MLL WITH (NOLOCK)		ON (MLL.LotID = MLI.LotID)  OR  (MLL.LotID = SPR.LotID)                             --OR문 추가
	        -- 기본라벨과 관련된 테이블
			LEFT OUTER JOIN STB_ModelLabelInfo MLBI WITH(NOLOCK)	ON MLBI.ModelCode = SPR.MaterialCode AND MLBI.LabelType = @LabelType
			LEFT OUTER JOIN LabelInfo LI				                            ON LI.LabelType = MLBI.LabelType          AND LI.FormatName = MLBI.FormatName  AND	LI.RankIndex = 1
           -- 포장라벨관련부분
		   LEFT OUTER JOIN STB_ModelBasicInfo MBI			                ON SPR.MaterialCode = MBI.ModelCode
			LEFT OUTER JOIN STB_PackingLabelSpec PLS			            ON SPR.LotID = PLS.LotID
	WHERE
			SPR.StocktakingDocNo = @StocktakingDocNo
 
     Order by SPR.SDNSeqNo ASC                                   --2020.07.14 추가
			 
END


--  Select * from STB_StocktakingPlanResult where PackingId like '%TEST%'
-- Select * from STB_StocktakingPlanResult where MaterialCode = 'ECVT23-008' 
-- Select * from STB_StocktakingPlanResult Order By CreateDateTime DESC


--select * from STB_MaterialLotInfo where