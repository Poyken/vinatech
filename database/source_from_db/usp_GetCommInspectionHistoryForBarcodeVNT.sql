
-- =============================================
-- Author:		Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-09-03
-- Browsable : true
-- Group : 품질관리
-- Description:	공용검사이력조회
-- Modified:
-- =============================================
-- EXEC [usp_GetCommInspectionHistoryForBarcode] 'kilee','Korean','ROUTE_QUALITY','VJJR023R036718','','','','',''
-- exec usp_GetCommInspectionHistoryForBarcode @pProcessUserID='kilee',@pProcessLanguage='Korean',@pCommInspTypeCode='ROUTE_QUALITY',@pBarcode='VJJR023R036718',@pLineCode=default,@pRouteCode=default,@pMachineCode=default,@pMoldNumber=default,@pCategoryName=default
-- EXEC [usp_GetCommInspectionHistoryForBarcode] 'kilee','Korean','ROUTE_QUALITY','VJJU292R718601','','','','',''

CREATE PROCEDURE [dbo].[usp_GetCommInspectionHistoryForBarcodeVNT]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCommInspTypeCode VARCHAR(50) = NULL,
	@pBarcode VARCHAR(50) = NULL,
	@pLineCode VARCHAR(20) = NULL,
	@pRouteCode VARCHAR(20) = NULL,
	@pMachineCode VARCHAR(20) = NULL,
	@pMoldNumber VARCHAR(50) = NULL,
	@pCategoryName VARCHAR(50) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
	DECLARE @CommInspTypeCode VARCHAR(50) = @pCommInspTypeCode
	DECLARE @Barcode VARCHAR(50) = @pBarcode
	DECLARE @LineCode VARCHAR(20) = ISNULL(@pLineCode,'')
	DECLARE @RouteCode VARCHAR(20) = ISNULL(@pRouteCode,'')
	DECLARE @MachineCode VARCHAR(20) = ISNULL(@pMachineCode,'')
	DECLARE @MoldNumber VARCHAR(50) = ISNULL(@pMoldNumber,'')
	DECLARE @CategoryName VARCHAR(50) = ISNULL(@pCategoryName,'')

	DECLARE @CommInspDocNo VARCHAR(20)
	DECLARE @CompanyCode VARCHAR(20)
	DECLARE @WorkCenterCode VARCHAR(20)
	DECLARE @PONo VARCHAR(20)
	DECLARE @ControlNo VARCHAR(20)
	DECLARE @IsFinished BIT
	DECLARE @ProductGroupCode VARCHAR(20)
	DECLARE @MaterialCode VARCHAR(50)
	DECLARE @IsLoss BIT
	DECLARE @IsHolding BIT
	DECLARE @ErrorMessage NVARCHAR(500)

	Declare @Size VARCHAR(10)

	SELECT @Size = CASE WHEN MBI.MBISizeW IN (22, 36) THEN 'L' ELSE 'SM' END
	  FROM STB_ModelBasicInfo MBI
	 WHERE ModelCode = (SELECT MaterialCode FROM STB_SetInfo WHERE Barcode = @Barcode)

	SELECT
			@CommInspDocNo = CIDH.CommInspDocNo,
			@IsFinished = CIDH.IsFinished,
			@CompanyCode = POI.CompanyCode,
			@WorkCenterCode = POI.WorkCenterCode,
			@PONo = SI.PONo,
			@ControlNo = SI.ControlNo,
			@MaterialCode = SI.MaterialCode,
			@ProductGroupCode = MM.ProductGroupCode,
			@IsLoss = SI.IsLoss,
			@IsHolding = ISNULL(SI.SIExtInt01,0)
	FROM
			STB_SetInfo SI
			LEFT OUTER JOIN STB_ProductionOrderInfo POI		ON POI.PONo = SI.PONo
			LEFT OUTER JOIN STB_CommInspDocHistory CIDH	ON CIDH.CommInspTypeCode = @CommInspTypeCode AND				CIDH.ProdNo = SI.ControlNo
			LEFT OUTER JOIN STB_MaterialMaster MM				ON MM.MaterialCode = SI.MaterialCode
	WHERE
			SI.Barcode = @Barcode

	IF ISNULL(@IsFinished,0) = 1 
	
		BEGIN
				EXEC SmartFramework.dbo.usp_GetAddonStringResource	@ProcessLanguage,
												'^이미 완료처리된 바코드입니다^',
												@ErrorMessage OUTPUT
				SET @ErrorMessage = @ErrorMessage + ' [%s]'
				RAISERROR(@ErrorMessage,16,1,@Barcode)
				RETURN
		END

	IF ISNULL(@IsHolding,0) = 1 
	
		BEGIN
				EXEC SmartFramework.dbo.usp_GetAddonStringResource	@ProcessLanguage,
												'^이미 부적합처리된 바코드입니다^',
												@ErrorMessage OUTPUT
				SET @ErrorMessage = @ErrorMessage + ' [%s]'
				RAISERROR(@ErrorMessage,16,1,@Barcode)
				RETURN
		END

	IF ISNULL(@Barcode,'') <> '' AND ISNULL(@CommInspTypeCode,'') <> '' BEGIN	-- Developer에서 화면 만들때는 생성하지 않게
		IF ISNULL(@CommInspDocNo,'') = '' BEGIN

				EXEC usp_DoCreateCommInspDocHistory	@pProcessLanguage = @ProcessLanguage,
																	@pProcessUserID = @ProcessUserID,
																	@pCommInspTypeCode = @CommInspTypeCode,
																	@pCompanyCode = @CompanyCode,
																	@pWorkCenterCode = @WorkCenterCode,
																	@pRefDoc = @PONo,
																	@pProdNo = @ControlNo,
																	@pProductGroupCode = @ProductGroupCode,
																	@pMaterialCode = @MaterialCode,
																	@pLineCode = @LineCode,
																	@pRouteCode = @RouteCode,
																	@pMachineCode = @MachineCode,
																	@pMoldNumber = @MoldNumber,
																	@pCategoryName = @CategoryName,
																	@pCommInspDocNo = @CommInspDocNo OUTPUT
		END
	END
    
	-- [MaxHist]
	;WITH MaxHist AS
	(
		SELECT
				CIMH.CommInspMeasureNo,
				CIMH.CommInspDocItemNo,
				CIMH.MeasureResult,
				CIMH.NumericMeasure,
				CIMH.TextMeasure,
				MAXMS.MeasureSeq
		FROM
				(
					SELECT
							CMH.CommInspDocItemNo,
							MAX(CMH.MeasureSeq) AS MeasureSeq
					FROM
							STB_CommInspDocItem CIDI
							INNER JOIN STB_CommInspMeasureHist CMH								ON	CMH.CommInspDocItemNo = CIDI.CommInspDocItemNo										
					WHERE
							CIDI.CommInspDocNo = @CommInspDocNo
					GROUP BY
							CMH.CommInspDocItemNo
				) MAXMS
				LEFT OUTER JOIN STB_CommInspMeasureHist CIMH					ON CIMH.CommInspDocItemNo = MAXMS.CommInspDocItemNo					AND CIMH.MeasureSeq = MAXMS.MeasureSeq
	)
   ,MeasureValue1 AS
	(
		SELECT
				CIMH.CommInspMeasureNo,
				CIMH.CommInspDocItemNo,
				CIMH.MeasureResult,
				CIMH.NumericMeasure,
				CIMH.TextMeasure,
				MAXMS.MeasureSeq
		FROM
				(
					SELECT
							CMH.CommInspDocItemNo,
							CMH.MeasureSeq
					FROM
							STB_CommInspDocItem CIDI
							INNER JOIN STB_CommInspMeasureHist CMH								ON	CMH.CommInspDocItemNo = CIDI.CommInspDocItemNo										
					WHERE   CIDI.CommInspDocNo = @CommInspDocNo
					  AND   CMH.MeasureSeq = 1
				) MAXMS
				LEFT OUTER JOIN STB_CommInspMeasureHist CIMH					ON CIMH.CommInspDocItemNo = MAXMS.CommInspDocItemNo					AND CIMH.MeasureSeq = MAXMS.MeasureSeq
	)
   ,MeasureValue2 AS
	(
		SELECT
				CIMH.CommInspMeasureNo,
				CIMH.CommInspDocItemNo,
				CIMH.MeasureResult,
				CIMH.NumericMeasure,
				CIMH.TextMeasure,
				MAXMS.MeasureSeq
		FROM
				(
					SELECT
							CMH.CommInspDocItemNo,
							CMH.MeasureSeq
					FROM
							STB_CommInspDocItem CIDI
							INNER JOIN STB_CommInspMeasureHist CMH								ON	CMH.CommInspDocItemNo = CIDI.CommInspDocItemNo										
					WHERE   CIDI.CommInspDocNo = @CommInspDocNo
					  AND   CMH.MeasureSeq = 2
				) MAXMS
				LEFT OUTER JOIN STB_CommInspMeasureHist CIMH					ON CIMH.CommInspDocItemNo = MAXMS.CommInspDocItemNo					AND CIMH.MeasureSeq = MAXMS.MeasureSeq
	)
   ,MeasureValue3 AS
	(
		SELECT
				CIMH.CommInspMeasureNo,
				CIMH.CommInspDocItemNo,
				CIMH.MeasureResult,
				CIMH.NumericMeasure,
				CIMH.TextMeasure,
				MAXMS.MeasureSeq
		FROM
				(
					SELECT
							CMH.CommInspDocItemNo,
							CMH.MeasureSeq
					FROM
							STB_CommInspDocItem CIDI
							INNER JOIN STB_CommInspMeasureHist CMH								ON	CMH.CommInspDocItemNo = CIDI.CommInspDocItemNo										
					WHERE   CIDI.CommInspDocNo = @CommInspDocNo
					  AND   CMH.MeasureSeq = 3
				) MAXMS
				LEFT OUTER JOIN STB_CommInspMeasureHist CIMH					ON CIMH.CommInspDocItemNo = MAXMS.CommInspDocItemNo					AND CIMH.MeasureSeq = MAXMS.MeasureSeq
	)
   ,MeasureValue4 AS
	(
		SELECT
				CIMH.CommInspMeasureNo,
				CIMH.CommInspDocItemNo,
				CIMH.MeasureResult,
				CIMH.NumericMeasure,
				CIMH.TextMeasure,
				MAXMS.MeasureSeq
		FROM
				(
					SELECT
							CMH.CommInspDocItemNo,
							CMH.MeasureSeq
					FROM
							STB_CommInspDocItem CIDI
							INNER JOIN STB_CommInspMeasureHist CMH								ON	CMH.CommInspDocItemNo = CIDI.CommInspDocItemNo										
					WHERE   CIDI.CommInspDocNo = @CommInspDocNo
					  AND   CMH.MeasureSeq = 4
				) MAXMS
				LEFT OUTER JOIN STB_CommInspMeasureHist CIMH					ON CIMH.CommInspDocItemNo = MAXMS.CommInspDocItemNo					AND CIMH.MeasureSeq = MAXMS.MeasureSeq
	)
   ,MeasureValue5 AS
	(
		SELECT
				CIMH.CommInspMeasureNo,
				CIMH.CommInspDocItemNo,
				CIMH.MeasureResult,
				CIMH.NumericMeasure,
				CIMH.TextMeasure,
				MAXMS.MeasureSeq
		FROM
				(
					SELECT
							CMH.CommInspDocItemNo,
							CMH.MeasureSeq
					FROM
							STB_CommInspDocItem CIDI
							INNER JOIN STB_CommInspMeasureHist CMH								ON	CMH.CommInspDocItemNo = CIDI.CommInspDocItemNo										
					WHERE   CIDI.CommInspDocNo = @CommInspDocNo
					  AND   CMH.MeasureSeq = 5
				) MAXMS
				LEFT OUTER JOIN STB_CommInspMeasureHist CIMH					ON CIMH.CommInspDocItemNo = MAXMS.CommInspDocItemNo					AND CIMH.MeasureSeq = MAXMS.MeasureSeq
	)
   ,MeasureValue6 AS
	(
		SELECT
				CIMH.CommInspMeasureNo,
				CIMH.CommInspDocItemNo,
				CIMH.MeasureResult,
				CIMH.NumericMeasure,
				CIMH.TextMeasure,
				MAXMS.MeasureSeq
		FROM
				(
					SELECT
							CMH.CommInspDocItemNo,
							CMH.MeasureSeq
					FROM
							STB_CommInspDocItem CIDI
							INNER JOIN STB_CommInspMeasureHist CMH								ON	CMH.CommInspDocItemNo = CIDI.CommInspDocItemNo										
					WHERE   CIDI.CommInspDocNo = @CommInspDocNo
					  AND   CMH.MeasureSeq = 6
				) MAXMS
				LEFT OUTER JOIN STB_CommInspMeasureHist CIMH					ON CIMH.CommInspDocItemNo = MAXMS.CommInspDocItemNo					AND CIMH.MeasureSeq = MAXMS.MeasureSeq
	)
   ,MeasureValue7 AS
	(
		SELECT
				CIMH.CommInspMeasureNo,
				CIMH.CommInspDocItemNo,
				CIMH.MeasureResult,
				CIMH.NumericMeasure,
				CIMH.TextMeasure,
				MAXMS.MeasureSeq
		FROM
				(
					SELECT
							CMH.CommInspDocItemNo,
							CMH.MeasureSeq
					FROM
							STB_CommInspDocItem CIDI
							INNER JOIN STB_CommInspMeasureHist CMH								ON	CMH.CommInspDocItemNo = CIDI.CommInspDocItemNo										
					WHERE   CIDI.CommInspDocNo = @CommInspDocNo
					  AND   CMH.MeasureSeq = 7
				) MAXMS
				LEFT OUTER JOIN STB_CommInspMeasureHist CIMH					ON CIMH.CommInspDocItemNo = MAXMS.CommInspDocItemNo					AND CIMH.MeasureSeq = MAXMS.MeasureSeq
	)
   ,MeasureValue8 AS
	(
		SELECT
				CIMH.CommInspMeasureNo,
				CIMH.CommInspDocItemNo,
				CIMH.MeasureResult,
				CIMH.NumericMeasure,
				CIMH.TextMeasure,
				MAXMS.MeasureSeq
		FROM
				(
					SELECT
							CMH.CommInspDocItemNo,
							CMH.MeasureSeq
					FROM
							STB_CommInspDocItem CIDI
							INNER JOIN STB_CommInspMeasureHist CMH								ON	CMH.CommInspDocItemNo = CIDI.CommInspDocItemNo										
					WHERE   CIDI.CommInspDocNo = @CommInspDocNo
					  AND   CMH.MeasureSeq = 8
				) MAXMS
				LEFT OUTER JOIN STB_CommInspMeasureHist CIMH					ON CIMH.CommInspDocItemNo = MAXMS.CommInspDocItemNo					AND CIMH.MeasureSeq = MAXMS.MeasureSeq
	)
   ,MeasureValue9 AS
	(
		SELECT
				CIMH.CommInspMeasureNo,
				CIMH.CommInspDocItemNo,
				CIMH.MeasureResult,
				CIMH.NumericMeasure,
				CIMH.TextMeasure,
				MAXMS.MeasureSeq
		FROM
				(
					SELECT
							CMH.CommInspDocItemNo,
							CMH.MeasureSeq
					FROM
							STB_CommInspDocItem CIDI
							INNER JOIN STB_CommInspMeasureHist CMH								ON	CMH.CommInspDocItemNo = CIDI.CommInspDocItemNo										
					WHERE   CIDI.CommInspDocNo = @CommInspDocNo
					  AND   CMH.MeasureSeq = 9
				) MAXMS
				LEFT OUTER JOIN STB_CommInspMeasureHist CIMH					ON CIMH.CommInspDocItemNo = MAXMS.CommInspDocItemNo					AND CIMH.MeasureSeq = MAXMS.MeasureSeq
	)
   ,MeasureValue10 AS
	(
		SELECT
				CIMH.CommInspMeasureNo,
				CIMH.CommInspDocItemNo,
				CIMH.MeasureResult,
				CIMH.NumericMeasure,
				CIMH.TextMeasure,
				MAXMS.MeasureSeq
		FROM
				(
					SELECT
							CMH.CommInspDocItemNo,
							CMH.MeasureSeq
					FROM
							STB_CommInspDocItem CIDI
							INNER JOIN STB_CommInspMeasureHist CMH								ON	CMH.CommInspDocItemNo = CIDI.CommInspDocItemNo										
					WHERE   CIDI.CommInspDocNo = @CommInspDocNo
					  AND   CMH.MeasureSeq = 10
				) MAXMS
				LEFT OUTER JOIN STB_CommInspMeasureHist CIMH					ON CIMH.CommInspDocItemNo = MAXMS.CommInspDocItemNo					AND CIMH.MeasureSeq = MAXMS.MeasureSeq
	)

	SELECT
			@Barcode AS Barcode,
			@ControlNo AS ControlNo,
			@IsLoss AS IsLoss,
			ISNULL(@IsFinished,0) AS IsFinished,
			CIDI.CommInspDocItemNo,
			CIDI.CommInspDocNo,
			CIDI.CommInspItemCode,
			CII.CommInspItemName,
			CIDI.CommInspUnit,
			CIDI.CommInspItemDesc,
			CIDI.CommInspInputType,
			VIEW_CIIT.CommInspInputTypeName,
			CIDI.CommInspItemSpec,
			CIDI.CommInspUpper,
			CIDI.CommInspLower,
			CIDI.ItemTargetQty,
			ISNULL(CIDI.ItemQty,0) AS ItemQty,
			ISNULL(CIDI.ImageFileID,0) AS ImageFileID,
			AFM.[FileName],
			AFM.FileSize,
			CONVERT(VARBINARY(MAX),NULL) AS FileData,
			CIDI.CommInspRemark,
			CII.CommInspSelectGroupCode,
			'' AS MeasureResult,
			0.0 AS NumericMeasure,
			CIMH2.TextMeasure AS TextMeasure,
			CISI.CommInspSelectItemCode,
			CISI.CommInspSelectItemValue,
			CISI.CommInspSelectResult,
			CASE 	WHEN ISNULL(CIMH.MeasureResult,'NG') = 'OK' THEN CONVERT(BIT,1)		ELSE CONVERT(BIT,0)		END AS CheckDisplay,
			CASE	WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN CONVERT(VARCHAR, CONVERT(NUMERIC(10,2), CIMH1.NumericMeasure))		ELSE CIMH1.MeasureResult			END AS FirstMeasureValue,
			CASE	WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN CONVERT(VARCHAR, CONVERT(NUMERIC(10,2), CIMH2.NumericMeasure))	ELSE CIMH2.MeasureResult			END AS SecondMeasureValue,
			CASE	WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN CONVERT(VARCHAR, CONVERT(NUMERIC(10,2), CIMH.NumericMeasure))		ELSE CIMH.MeasureResult			END AS LastMeasureValue,
			CASE	WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN CONVERT(VARCHAR, CONVERT(NUMERIC(10,2), CIMH.NumericMeasure))		ELSE CIMH.MeasureResult			END AS OldLastMeasureValue,
			CIMH.CommInspMeasureNo,
			CIMH.MeasureSeq,
			'' AS DefectCode,
			CONVERT(BIT,0) AS IsHolding,
			CII.DisplayIndex
	FROM			
			STB_CommInspDocItem CIDI
			LEFT OUTER JOIN STB_CommInspItem CII				                            ON CII.CommInspItemCode = CIDI.CommInspItemCode
			LEFT OUTER JOIN VW_CommInspInputType VIEW_CIIT 				            ON VIEW_CIIT.CommInspInputType = CIDI.CommInspInputType
			LEFT OUTER JOIN SmartFramework_File.dbo.STB_AttachedFileMaster AFM		ON (AFM.FileID = CIDI.ImageFileID)
			LEFT OUTER JOIN FirstHist CIMH1														ON CIMH1.CommInspDocItemNo = CIDI.CommInspDocItemNo
			LEFT OUTER JOIN SecondHist CIMH2														ON CIMH2.CommInspDocItemNo = CIDI.CommInspDocItemNo
			LEFT OUTER JOIN MaxHist CIMH														ON CIMH.CommInspDocItemNo = CIDI.CommInspDocItemNo
			LEFT OUTER JOIN STB_CommInspSelectItem CISI WITH(NOLOCK)				ON CISI.CommInspSelectResult = CIMH.MeasureResult				AND CISI.CommInspSelectGroupCode = CII.CommInspSelectGroupCode
	WHERE CIDI.CommInspDocNo = @CommInspDocNo
	  AND (CII.CommInspItemGroup3 IS NULL OR CII.CommInspItemGroup3 LIKE '%' + @Size + '%')
	  AND CII.DisplayIndex < 100
	ORDER BY CII.DisplayIndex

END


--  SELECT CommInspDocItemNo, CommInspItemSpec, * from STB_CommInspDocItem where  ComminspDocitemNo in ( '20190902001244', '20190902001245', '20190904001276', '20190902001242', '20190902001247', '20190902001248', '20190902001249')

-- SELECT CommInspDocItemNo, CommInspItemSpec, * from STB_CommInspDocItem where  ComminspDocitemNo = '20190904001276'

-- select * from Stb_Setinfo where barcode = 'VJJR023R036718'    -- ControlNo : 20190902000060 / PONO : 190831000001


--- [ 스펙변경 UPDATE문]


--   SELECT CommInspItemSpec, CommInspUpper,  CommInspLower, * FROM STB_CommInspDocItem where ComminspDocitemNo = '20190904001276'  

--Begin tran
---- Commit
--update STB_CommInspDocItem
--Set CommInspItemSpec = 62.20
--   , CommInspUpper = 62.35
--   , CommInspLower = 62.05
--FROM STB_CommInspDocItem where ComminspDocitemNo = '20190904001276'  


--   SELECT CommInspItemSpec, CommInspUpper,  CommInspLower, * FROM STB_CommInspDocItem where ComminspDocitemNo = '20190904001276'  




-- select * from STB_CommInspMeasureHist where ComminspMeasureNo = '20191230000176'


--Begin tran
---- commit
--update STB_CommInspMeasureHist
--set TextMeasure = 'TEST'
--where ComminspMeasureNo = '20191230000176'