
-- =============================================
-- Author:	Kangs (kilee@vina.co.kr)
-- Create date: 2021-02-17
-- Browsable : True
-- Group : 공통
-- Description:	자재정보 >  [F431] 비나텍 원자재불출현황
-- Modified:
--                2021-04-05 김은초롱 요청 화면
--                2021-04-15 데이터검증 (김은초롱)

--  [프로시저 실행 - 2021-04-15]      usp_RawMaterialDelivery_get 'kilee', 'Korean'  ,'2021-04-01 00:00:00','2021-04-30 17:20:00', '', '', 'VVT'        --(3501)
-- =======================================================================================================
CREATE PROCEDURE [dbo].[usp_RawMaterialDelivery_get]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
					--	@pMaterialDocNo VARCHAR(20) = NULL,
						@pFromDate DATE = NULL,
						@pToDate DATE = NULL,
						@pMaterialDocType VARCHAR(20) = NULL,	
						@pMaterialDocTypeCode VARCHAR(20) = NULL, 
						@pSourceCompanyCode VARCHAR(20) = Null,
						@pDocStatus  VARCHAR(20) = Null
AS

BEGIN
	SET NOCOUNT ON;

--	DECLARE @MaterialDocNo         Varchar(20) = CASE WHEN ISNULL(@pMaterialDocNo,'') = '' THEN '' ELSE @pMaterialDocNo END
	DECLARE @FromDate                Date        = @pFromDate
	DECLARE @ToDate                   Date        = @pToDate
	DECLARE @MaterialDocType       Varchar(20) =  CASE WHEN ISNULL(@pMaterialDocType,'') = '' THEN '*' ELSE @pMaterialDocType END
	DECLARE @MaterialDocTypeCode Varchar(20) =  CASE WHEN ISNULL(@pMaterialDocTypeCode,'') = '' THEN '*' ELSE @pMaterialDocTypeCode END
	DECLARE @PickingAssignQty       Int
	DECLARE @SourceCompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pSourceCompanyCode,'') = '' THEN '%' ELSE @pSourceCompanyCode END
	DECLARE @DocStatus                Varchar(20) =  CASE WHEN ISNULL(@pDocStatus,'') = '' THEN '*' ELSE @pDocStatus END

  SELECT MDI.SourceCompanyCode ,
			--MDD.MaterialDocDetailNo,
			--MDD.MaterialDocNo,
			--MDD.OrderDetailNo,
			MDD.MaterialCode,
			MDD.MaterialStockAttribute,
			--MSAI.IsVendorLotUse,
			--MSAI.IsUseBarcode,
			--MDD.StockAttrib1,
			--MDD.StockAttrib2,
			--MDD.StockAttrib3,
			MM.MaterialName,
			--MM.MaterialNameL,
			--MM.MaterialSpec,
			MM.MaterialTypeCode,
			MT.MaterialTypeName,
			MM.ProductGroupCode,
			PG.ProductGroupName,			
			ISNULL(MM.BasicGrQty, 1) AS BasicGrQty,
			MM.MaterialUnit,
			--MOI.MaterialOrderQty,
			--MOI.MaterialOrderRemainQty,						
			ISNULL((
							SELECT
									ISNULL(SUM(ROUND(MS.StockQty, 0) ),0)                                                    -- 소숫점제거 (kilee, 2019-11-19)
							FROM
									STB_MaterialStock MS WITH(NOLOCK)
							WHERE
									MS.MaterialWarehouseCode = MDI.SourceMaterialWarehouseCode AND
									MS.MaterialCode = MDD.MaterialCode AND
									MS.MaterialStockAttribute = MDD.MaterialStockAttribute AND
									MS.StockAttrib1 = MDD.StockAttrib1 AND
									MS.StockAttrib2 = MDD.StockAttrib2 AND
									MS.StockAttrib3 = MDD.StockAttrib3
						),0) AS StockQty,
			--SOI.OrderQty AS SalesOrderQty,
			--SOI.FixedQty AS SalesFixedQty,
			--SOI.GIPlanQty,
			--SOI.GIFixQty,
			--SOI.FixedQty - SOI.GIPlanQty - SOI.GIFixQty AS GIRemainQty,
			--0 AS RequestBoxQty,
			MDD.RequestQty,
			MDD.AllowQty,
			Case When MDD.PickingAssignQty = 0 Then MDD.RequestQty ELSE MDD.PickingAssignQty END AS PickingAssignQty,                                                                                                               
			MDD.PickingQty,
			MDD.ProcessFixQty,
			--MDD.UnitPriceQty,
			--MDD.UnitPrice,
			--MDD.InspectionType,
			--MDD.MaterialIqcNo,
			--MII.DecisionResult,
			--DR.DecisionResultText,
			--AFM.[FileName],
			--AFM.FileSize,
			CONVERT(VARBINARY(MAX),NULL) AS FileData,
			MII.VendorQcReport,
			MDD.VendorLotNo,
			MDD.BefMaterialStockAttribute,
			--MDD.MRMDExtText01,
			MDD.MRMDExtText02,
			--MDD.MRMDExtText03,
			MDD.MRMDExtText04,			--MODEL
			MDD.MRMDExtText05,
			--MDD.MDDErpRefText01,
			--MDD.MDDErpRefText02,
			--MDD.MDDErpRefText03,
			--MDD.MDDErpRefText04,
			--MDD.MDDErpRefText05,
			--MDD.MDDErpRefText06,
			--MDD.MDDErpRefText07,
			--MDD.MDDErpRefText08,
			--MDD.MDDErpRefText09,
			--MDD.MDDErpRefText10,
			--SO.SOExtText01,
			--SO.SOExtText02,
			--SO.SOExtText03,
			--SO.SOExtText04,
			--SO.SOExtText05,
			--SOI.SOIExtText01,
			--SOI.SOIExtText02,
			--SOI.SOIExtText03,
			--SOI.SOIExtText04,
			--SOI.SOIExtText05,
			--SOI.OptionText,
			MDD.CreateDateTime,
			MDD.CreateUserID,
			--MDD.ChangeDateTime,
			--MDD.ChangeUserID,
			--MM.AltMaterialCode,
			CASE WHEN ISNULL(MM.BasicPackingQty,0) = 0 THEN 1 ELSE MM.BasicPackingQty END   AS BasicPackingQty,
			CONVERT(NUMERIC(20,5),0) AS PackingQty	                                 -- 입고라벨 발행에서 사용
			, MM.BasicCostPrice           AS BasicCostPrice                                  -- 표준원가 ( 2021.03.29, 김은초롱 추가)
			, MDI.BasicDate                 AS BasicDate                                        -- 2021.04.06 추가
			, MDI.DocStatus                AS DocStatus                                       -- /* select DocStatus from STB_MaterialDocInfo Group by DocStatus */
	FROM
			STB_MaterialDocDetail MDD WITH(NOLOCK)
			INNER JOIN STB_MaterialDocInfo MDI WITH(NOLOCK)				    ON  MDI.MaterialDocNo = MDD.MaterialDocNo
			LEFT OUTER JOIN STB_MaterialOrderItem MOI WITH(NOLOCK)		ON (MDI.MaterialDocType = 'GR' AND MOI.MaterialOrderItemNo = MDD.OrderDetailNo)
			LEFT OUTER JOIN STB_SalesOrderItem SOI WITH(NOLOCK)			ON (MDI.MaterialDocType = 'GI' AND SOI.SOISequence = MDD.OrderDetailNo)
			LEFT OUTER JOIN STB_SalesOrder SO WITH (NOLOCK)				    ON (MDI.MaterialDocType = 'GI' AND SO.SalesOrderNo = SOI.SalesOrderNo)
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)			ON (MM.MaterialCode = MDD.MaterialCode)
			LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK)				ON (MT.MaterialTypeCode = MM.MaterialTypeCode)
			LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)				ON (PG.ProductGroupCode = MM.ProductGroupCode)
			LEFT OUTER JOIN STB_MaterialQcInfo MII WITH(NOLOCK)				ON MII.MaterialQcNo = MDD.MaterialIqcNo
			LEFT OUTER JOIN SmartFramework_File.dbo.STB_AttachedFileMaster AFM WITH (NOLOCK)	ON (AFM.FileID = MII.VendorQcReport)
			LEFT OUTER JOIN VW_DecisionResult DR				                               ON DR.DecisionResult = MII.DecisionResult
			LEFT OUTER JOIN STB_MaterialStockAttributeInfo MSAI WITH(NOLOCK)	   ON MSAI.MaterialCode = MDD.MaterialCode
	WHERE 1=1
	  -- AND ((@FromDate IS NULL) OR (@FromDate <= MDI.BasicDate))    -- 원본백업
	  -- AND (MDI.DocStatus IS NULL OR MDI.DocStatus LIKE @DocStatus) 

	   AND                 ((@FromDate IS NULL) OR (MDI.BasicDate  BETWEEN @FromDate AND @ToDate ))     -- 2021.04.06 변경
	   AND (MDI.SourceCompanyCode IS NULL OR MDI.SourceCompanyCode  LIKE @SourceCompanyCode) 
	   AND MDI.DocStatus = 'FIX'                                                                                                     -- 2021.04.15 추가
	   AND MM.MaterialTypeCode LIKE '%ROH%'
END