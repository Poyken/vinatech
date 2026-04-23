-- ========================================================================================================================
-- Author: Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2016-06-19
-- Browsable : True
-- Group : 공통
-- Description:	자재수불상세정보 ,  [F411] 생산출고요청화면 하단탭, [F320] 자재입고 수불상세 하단탭, [F414] 사내창고 이동 상세내역
-- Modified:
-- 2016-07-23 Kim Han Young
-- 파라미터에 @pFromDate, @pToDate, @pMaterialDocType, @pMaterialDocTypeCode 추가

-- 프로시저실행 : EXEC [usp_MaterialDocDetail_get] 'DinhManh','vi','260213000236','','2025-02-13 00:00:00','2025-02-13 23:20:00',''
-- ========================================================================================================================

CREATE PROCEDURE [dbo].[usp_MaterialDocDetail_get]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pMaterialDocNo VARCHAR(20) = NULL,
						@pFromDate DATE = NULL,
						@pToDate DATE = NULL,
						@pMaterialDocType VARCHAR(20) = NULL,	-- 수불유형
						@pMaterialDocTypeCode VARCHAR(20) = NULL	-- 수불문서 유형
AS

BEGIN
	SET NOCOUNT ON;

	DECLARE @MaterialDocNo         Varchar(20) = CASE WHEN ISNULL(@pMaterialDocNo,'') = '' THEN '' ELSE @pMaterialDocNo END
	DECLARE @FromDate                Date        = @pFromDate
	DECLARE @ToDate                   Date        = @pToDate
	DECLARE @MaterialDocType       Varchar(20) =  CASE WHEN ISNULL(@pMaterialDocType,'') = '' THEN '*' ELSE @pMaterialDocType END
	DECLARE @MaterialDocTypeCode Varchar(20) =  CASE WHEN ISNULL(@pMaterialDocTypeCode,'') = '' THEN '*' ELSE @pMaterialDocTypeCode END
	DECLARE @PickingAssignQty       Int

   --  2020.04.02 추가부분
			 Select 
			        @PickingAssignQty 		 = PickingAssignQty	   
			 From STB_MaterialDocDetail 
			 where 1=1
			   AND MaterialDocNo = @MaterialDocNo
			   --And MaterialDocDetailNo = @MaterialDocNo
			    --And MaterialDocDetailNo = '200406000025'                   -- TEST용 추후삭제

			IF  @PickingAssignQty = 0.00000
						
				 UPDATE STB_MaterialDocDetail
					  SET PickingAssignQty = RequestQty
				  WHERE  1=1
				  AND MaterialDocNo = @MaterialDocNo
				  --AND MaterialDocDetailNo = @MaterialDocNo
			    --AND MaterialDocDetailNo = '200406000025'                 -- TEST용 추후삭제
					 			
    
	;WITH MaterialDocLotCTE (MaterialDocNo, MaterialDocDetailNo, ScanQty)
			AS
			(
				SELECT
						MDLI.MaterialDocNo,
						MDLI.MaterialDocDetailNo,
						ISNULL(SUM(MDLI.StockQty),0) AS ScanQty
				FROM
						STB_MaterialDocLotInfo MDLI WITH(NOLOCK)
						--LEFT OUTER JOIN STB_MaterialDocDetail MDD WITH(NOLOCK) ON MDD.MaterialDocDetailNo = MDLI.MaterialDocDetailNo
						--LEFT OUTER JOIN STB_MaterialDocInfo MDI WITH(NOLOCK)    ON MDI.MaterialDocNo         = MDLI.MaterialDocNo
				WHERE 1=1
				--AND ((MDD.MaterialDocNo = @MaterialDocNo) OR (@MaterialDocNo = '*')) 
				  AND ((MDLI.MaterialDocNo = @MaterialDocNo)) 
				--AND ((@FromDate IS NULL) OR (@FromDate <= MDI.BasicDate))
				--AND ((@ToDate IS NULL) OR (MDI.BasicDate < DATEADD(DD,1,@ToDate))) 
				--AND ((MDI.MaterialDocType = @MaterialDocType) OR (@MaterialDocType = '*') ) 
				--AND ((MDI.MaterialDocTypeCode = @MaterialDocTypeCode) OR (@MaterialDocTypeCode = '*') ) 
				  AND ((MDLI.IsChecked = 1))
				GROUP BY
						MDLI.MaterialDocNo,
						MDLI.MaterialDocDetailNo
			 )			

	SELECT
			MDD.MaterialDocDetailNo AS OldMaterialDocDetailNo,
			MDD.MaterialDocNo AS OldMaterialDocNo,
			MDD.MaterialDocDetailNo,
			MDD.MaterialDocNo,
			MDD.OrderDetailNo,
			MDD.MaterialCode,
			MDD.Line as ImportLine,
			MDD.MachineCode,
			MDD.MaterialStockAttribute,
			MSAI.IsVendorLotUse,
			MSAI.IsUseBarcode,
			MDD.ManufacturerCode,
			CI.CustomerName AS ManufacturerName,
			MDD.WeekCode,
			MDD.RevisionsVer,
			MDD.StockAttrib1,
			MDD.StockAttrib2,
			MDD.StockAttrib3,
			CASE 
				WHEN MDD.MaterialCode = 'GBAKAC-608' THEN REPLACE(MM.MaterialName, '(', '-600F(')
				WHEN MDD.MaterialCode = 'GBAKAC-048' THEN REPLACE(MM.MaterialName, '(', '-VPC(')
				WHEN MDD.MaterialCode = 'GBAKAC-039' THEN REPLACE(MM.MaterialName, '(', '-VPC(')
				WHEN MDD.MaterialCode = 'GBAKAC-050' THEN REPLACE(MM.MaterialName, '(', '-VPC(')
				WHEN MDD.MaterialCode = 'GBAKAC-033' THEN REPLACE(MM.MaterialName, '(', '-500F(')
				ELSE MM.MaterialName 
			END AS MaterialName,
			MM.MaterialNameL,
			MM.MaterialSpec,
			MM.MaterialTypeCode,
			MT.MaterialTypeName,
			MM.ProductGroupCode,
			PG.ProductGroupName,			
			ISNULL(MM.BasicGrQty, 1) AS BasicGrQty,
			MM.MaterialUnit,
			MOI.MaterialOrderQty,
			MOI.MaterialOrderRemainQty,						
			ISNULL((
							SELECT
									--ISNULL(SUM(MS.StockQty),0)
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
			SOI.OrderQty AS SalesOrderQty,
			SOI.FixedQty AS SalesFixedQty,
			SOI.GIPlanQty,
			SOI.GIFixQty,
			SOI.FixedQty - SOI.GIPlanQty - SOI.GIFixQty AS GIRemainQty,
			0 AS RequestBoxQty,
			MDD.RequestQty,
			MDD.AllowQty,
			Case When MDD.PickingAssignQty = 0 Then MDD.RequestQty ELSE MDD.PickingAssignQty END AS PickingAssignQty,    -- 원본변경 (kilee, 2020-03-30)
		  --MDD.PickingAssignQty,                                                                                                                      -- 원본
			MDD.PickingQty,
			MDD.ProcessFixQty,
			MDD.UnitPriceQty,
			MDD.UnitPrice,
			MDD.InspectionType,
			MDD.MaterialIqcNo,
			MII.DecisionResult,
			DR.DecisionResultText,
			AFM.[FileName],
			AFM.FileSize,
			CONVERT(VARBINARY(MAX),NULL) AS FileData,
			MII.VendorQcReport,
			MDD.VendorLotNo,
			MDD.BefMaterialStockAttribute,
			MDD.MRMDExtText01,
			MDD.MRMDExtText02,
			MDD.MRMDExtText03,
			MDD.MRMDExtText04,			--MODEL
			MDD.MRMDExtText05,
			MDD.MDDErpRefText01,
			MDD.MDDErpRefText02,
			MDD.MDDErpRefText03,
			MDD.MDDErpRefText04,
			MDD.MDDErpRefText05,
			MDD.MDDErpRefText06,
			MDD.MDDErpRefText07,
			MDD.MDDErpRefText08,
			MDD.MDDErpRefText09,
			MDD.MDDErpRefText10,
			SO.SOExtText01,
			SO.SOExtText02,
			SO.SOExtText03,
			SO.SOExtText04,
			SO.SOExtText05,
			SOI.SOIExtText01,
			SOI.SOIExtText02,
			SOI.SOIExtText03,
			SOI.SOIExtText04,
			SOI.SOIExtText05,
			SOI.OptionText,
			MDD.CreateDateTime,
			MDD.CreateUserID,
			MDD.ChangeDateTime,
			MDD.ChangeUserID,
			MM.AltMaterialCode,
			ISNULL(MDLCTE.ScanQty,0) AS ScanQty,
			MDD.PickingAssignQty - ISNULL(MDLCTE.ScanQty,0) AS RemainScanQty,
			0 AS LabelQty,							                                                                                           	-- 입고라벨 발행에서 사용
			CASE WHEN ISNULL(MM.BasicPackingQty,0) = 0 THEN 1 ELSE MM.BasicPackingQty END AS BasicPackingQty,
			0 AS BoxQty,
			CONVERT(NUMERIC(20,5),0) AS PackingQty,
			LI.LineName AS LineCode, -- 입고라벨 발행에서 사용
			MDD.MDDExtBit01,
			MDD.MDDExtBit02
	FROM
			STB_MaterialDocDetail MDD WITH(NOLOCK)
			INNER JOIN STB_MaterialDocInfo MDI WITH(NOLOCK)				    ON	MDI.MaterialDocNo = MDD.MaterialDocNo
			LEFT OUTER JOIN STB_MaterialOrderItem MOI WITH(NOLOCK)			ON (MDI.MaterialDocType = 'GR' AND MOI.MaterialOrderItemNo = MDD.OrderDetailNo)
			LEFT OUTER JOIN STB_SalesOrderItem SOI WITH(NOLOCK)				ON (MDI.MaterialDocType = 'GI' AND SOI.SOISequence = MDD.OrderDetailNo)
			LEFT OUTER JOIN STB_SalesOrder SO WITH (NOLOCK)				    ON (MDI.MaterialDocType = 'GI' AND SO.SalesOrderNo = SOI.SalesOrderNo)
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)				ON (MM.MaterialCode = MDD.MaterialCode)
			LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK)				    ON (MT.MaterialTypeCode = MM.MaterialTypeCode)
			LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)				ON (PG.ProductGroupCode = MM.ProductGroupCode)
			LEFT OUTER JOIN MaterialDocLotCTE MDLCTE				                ON MDLCTE.MaterialDocNo = MDD.MaterialDocNo				AND MDLCTE.MaterialDocDetailNo = MDD.MaterialDocDetailNo
			LEFT OUTER JOIN STB_MaterialQcInfo MII WITH(NOLOCK)				ON MII.MaterialQcNo = MDD.MaterialIqcNo
			LEFT OUTER JOIN SmartFramework_File.dbo.STB_AttachedFileMaster AFM WITH (NOLOCK)				ON (AFM.FileID = MII.VendorQcReport)
			LEFT OUTER JOIN VW_DecisionResult DR				                           ON DR.DecisionResult = MII.DecisionResult
			LEFT OUTER JOIN STB_MaterialStockAttributeInfo MSAI WITH(NOLOCK)	   ON MSAI.MaterialCode = MDD.MaterialCode
			LEFT OUTER JOIN STB_LineInfo LI WITH(NOLOCK) ON LI.LineCode = MDD.Line
			LEFT OUTER JOIN STB_CustomerInfo CI WITH(NOLOCK) ON CI.CustomerCode = MDD.ManufacturerCode
	WHERE
			--((MDD.MaterialDocNo = @MaterialDocNo) OR (@MaterialDocNo = '*') ) AND
			((MDD.MaterialDocNo = @MaterialDocNo)) --AND
			--((@FromDate IS NULL) OR (@FromDate <= MDI.BasicDate)) AND
			--((@ToDate IS NULL) OR (MDI.BasicDate < DATEADD(DD,1,@ToDate))) AND
			--((MDI.MaterialDocType = @MaterialDocType) OR (@MaterialDocType = '*')) AND
			--((MDI.MaterialDocTypeCode = @MaterialDocTypeCode) OR (@MaterialDocTypeCode = '*') ) 

END