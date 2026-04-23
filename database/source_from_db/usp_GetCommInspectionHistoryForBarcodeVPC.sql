
-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2021-11-04
-- Browsable : true
-- Group : 품질관리
-- Description:	VPC 0825 전용 자주검사 조회화면
-- =============================================

CREATE PROCEDURE [dbo].[usp_GetCommInspectionHistoryForBarcodeVPC]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pCommInspTypeCode VARCHAR(50) = NULL,
						@pBarcode VARCHAR(50) = NULL,
						@pLineCode VARCHAR(20) = NULL,
						@pRouteCode VARCHAR(20) = NULL,
						@pMachineCode VARCHAR(20) = NULL,
						@pMoldNumber VARCHAR(50) = NULL,
						@pCategoryName VARCHAR(50) = NULL,
						@pCommInspRemark VARCHAR(50) = NULL
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
	DECLARE @CommInspRemark VARCHAR(50) = @pCommInspRemark
	DECLARE @ProductType INT
	DECLARE @NewBarcode VARCHAR(50)

	Declare @Size VARCHAR(10)
	Declare @IsExceptDestInsp BIT

	Declare @MeasureTableMAX TABLE (
		CommInspMeasureNo VARCHAR(20),
		CommInspDocItemNo VARCHAR(20),
		MeasureResult VARCHAR(20),
		NumericMeasure NUMERIC(20,5),
		TextMeasure VARCHAR(50),
		MeasureSeq INT
	);

	CREATE TABLE #MeasureTable (
		CommInspMeasureNo VARCHAR(20),
		CommInspDocItemNo VARCHAR(20),
		MeasureResult VARCHAR(20),
		NumericMeasure NUMERIC(20,5),
		TextMeasure VARCHAR(50),
		MeasureSeq INT
	);

	SELECT @Size = CASE WHEN MBI.MBISizeW IN (22, 36) THEN 'L' ELSE 'SM' END
	  FROM STB_ModelBasicInfo MBI
	 WHERE ModelCode = (SELECT MaterialCode FROM STB_SetInfo WHERE Barcode = @Barcode)

	SELECT @NewBarcode = NewBarcode
	  FROM STB_LotChangeMaterialHistory WITH(NOLOCK)
	 WHERE OldBarcode = @Barcode

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
			@IsHolding = ISNULL(SI.SIExtInt01,0),
			@ProductType = MBI.MBISizeW,				--제품 직경 저장 변수
			-- 중/대형 자주검사에서 일부 검사항목(파괴검사 등)을 제외하였으나 자주검사 실행여부 추가 관계로 원복요청
			-- 2020.04.06 조현준 셀장님
			@IsExceptDestInsp = CONVERT(BIT, 0) --CASE WHEN MBI.MBISizeW IN (8, 10) THEN CONVERT(BIT, 0) ELSE CONVERT(BIT, 1) END
	FROM
								  STB_SetInfo SI
			LEFT OUTER JOIN STB_ProductionOrderInfo POI		ON POI.PONo = SI.PONo
			LEFT OUTER JOIN STB_CommInspDocHistory CIDH	ON CIDH.CommInspTypeCode = @CommInspTypeCode AND				CIDH.ProdNo = SI.ControlNo
			LEFT OUTER JOIN STB_MaterialMaster MM				ON MM.MaterialCode = SI.MaterialCode
			LEFT OUTER JOIN STB_ModelBasicInfo MBI		ON MM.MaterialCode = MBI.ModelCode
	WHERE 1=1
	    -- AND SI.Barcode = @Barcode                                                                                                                                                     -- 원본백업
		   AND SI.Barcode = @Barcode OR SI.Barcode = @NewBarcode            -- 2020.04.17 추가 (기종변경 바코드추가) 

	-- 크기에 상관없이 베트남이면 0
	IF @CompanyCode = 'VVT' BEGIN
		SET @IsExceptDestInsp = CONVERT(BIT, 0)
	END

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

	--#211007 ROUTE_TEST_VPC != LIVT-018 이거나 ROUTE_TEST == LIVT-018 인 경우를 체크함.
	IF @CommInspTypeCode = 'ROUTE_TEST' AND @MaterialCode = 'LIVT38-018' BEGIN
		EXEC SmartFramework.dbo.usp_GetAddonStringResource	@ProcessLanguage,
												'^VPC 0825제품입니다. [자주검사(VPC)] 화면에서 입력하세요.^',
												@ErrorMessage OUTPUT
				SET @ErrorMessage = @ErrorMessage + ' [%s]'
				RAISERROR(@ErrorMessage,16,1,@Barcode)
				RETURN
	END

	IF @CommInspTypeCode = 'ROUTE_TEST_VPC' AND @MaterialCode <> 'LIVT38-018' BEGIN
		EXEC SmartFramework.dbo.usp_GetAddonStringResource	@ProcessLanguage,
												'^VPC 0825제품이 아닙니다. 기존 자주검사 화면에서 입력하세요.^',
												@ErrorMessage OUTPUT
				SET @ErrorMessage = @ErrorMessage + ' [%s]'
				RAISERROR(@ErrorMessage,16,1,@Barcode)
				RETURN
	END

	IF ISNULL(@Barcode,'') <> '' AND ISNULL(@CommInspTypeCode,'') <> ''      -- Developer에서 화면 만들때는 생성하지 않게
	
	 BEGIN	
		IF ISNULL(@CommInspDocNo,'') = '' 
		
		   BEGIN
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

	INSERT INTO @MeasureTableMAX
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
							MAX(CMH.MeasureSeq)      AS MeasureSeq							
					FROM
							                STB_CommInspDocItem     CIDI
							INNER JOIN STB_CommInspMeasureHist CMH
							   ON	CMH.CommInspDocItemNo = CIDI.CommInspDocItemNo										
					WHERE
							CIDI.CommInspDocNo = @CommInspDocNo
					GROUP BY
							CMH.CommInspDocItemNo							
				) MAXMS
				LEFT OUTER JOIN STB_CommInspMeasureHist CIMH
				  ON CIMH.CommInspDocItemNo = MAXMS.CommInspDocItemNo
				 AND CIMH.MeasureSeq = MAXMS.MeasureSeq

	Declare @cnt INT = 1

	WHILE @cnt <= 9 BEGIN
		INSERT INTO #MeasureTable
			SELECT
					A.CommInspMeasureNo,
					A.CommInspDocItemNo,
					A.MeasureResult,
					A.NumericMeasure,
					A.TextMeasure,
					A.MeasureSeq				
			FROM
					(
				 SELECT
					CIMH2.CommInspMeasureNo,
					CIMH2.CommInspDocItemNo,
					CIMH2.MeasureResult,
					CIMH2.NumericMeasure,
					CIMH2.TextMeasure,
					MAXMS2.MeasureSeq				
			FROM
					(
						SELECT
								CMH.CommInspDocItemNo,
								CMH.MeasureSeq							
						FROM
								STB_CommInspDocItem CIDI
								INNER JOIN STB_CommInspMeasureHist CMH
								   ON CMH.CommInspDocItemNo = CIDI.CommInspDocItemNo										
						WHERE   CIDI.CommInspDocNo = @CommInspDocNo
						  AND   CMH.MeasureSeq = @cnt
					) MAXMS2
					LEFT OUTER JOIN STB_CommInspMeasureHist CIMH2
					  ON CIMH2.CommInspDocItemNo = MAXMS2.CommInspDocItemNo
					 AND CIMH2.MeasureSeq = MAXMS2.MeasureSeq
			) A

		SET @cnt = @cnt + 1
	
	END

	CREATE NONCLUSTERED INDEX XS_TEMPINDEX ON #MeasureTable (CommInspDocItemNo)
	CREATE NONCLUSTERED INDEX XS_TEMPINDEX2 ON #MeasureTable (MeasureSeq)

	-- [최종 Select문]
	SELECT
			@Barcode    AS Barcode,
			@ControlNo AS ControlNo,
			@IsLoss      AS IsLoss,
			ISNULL(@IsFinished,0) AS IsFinished,
			CIDI.CommInspDocItemNo,
			CIDI.CommInspDocNo,
			CIDI.CommInspItemCode,
			CASE WHEN CIDI.CommInspItemCode = 'WAppInsp' AND @MaterialCode IN ('LIVT38-007', 'LIVT38-008', 'LIVT38-009', 'LIVT38-010', 'LIVT38-016')  
			     THEN CII.CommInspItemName + '(권취소자 하단 전극 돌출 확인)' 
				 ELSE CII.CommInspItemName END AS CommInspItemName,                               -- 점검항목명 --VPC 일부품목의 경우 점검항목명을 변경적용.
			CIDI.CommInspUnit,
			CIDI.CommInspItemDesc,                                --- 한국어 항목설명 
			CIDI.CommInspInputType,
			VIEW_CIIT.CommInspInputTypeName,
			CIDI.CommInspItemSpec,                                 -- LSE 스펙하한값
			CONVERT(NUMERIC(20,2), CASE WHEN CIDI.CommInspUpper = '' THEN NULL ELSE CIDI.CommInspUpper END) AS CommInspUpper,
			CONVERT(NUMERIC(20,2), CASE WHEN CIDI.CommInspLower = '' THEN NULL ELSE CIDI.CommInspLower END) AS CommInspLower,
			CIDI.ItemTargetQty,                                                                                                                                                                  -- 검사시료수

			--ISNULL(CIDI.ItemQty,0)																													         AS ItemQty,                -- 원본백업 (현재검사수)
			CASE WHEN ISNULL(CIDI.ItemQty,0)	>= CIDI.ItemTargetQty      THEN CIDI.ItemTargetQty 
			        WHEN CIDI.ItemTargetQty = '20' AND CIDI.ItemQty <> '0' THEN '20'                      ELSE ISNULL(CIDI.ItemQty,0) END   AS ItemQty,                -- 2020.01.31 수정 - 현재검사수

			--ISNULL(CIDI.ImageFileID,0) AS ImageFileID,
			AFM.[FileName],
			AFM.FileSize,
			CONVERT(VARBINARY(MAX),NULL)                                                                                                                   AS FileData,
		 -- CIDI.CommInspRemark																			   											         AS CommInspRemark ,              -- 원본백업
			CASE WHEN CII.DisplayIndex = 1 THEN SCH.CIDHExtText02 ELSE '' END                                                                AS CIDHExtText02,               -- 2020.01.13 비고정보 수정 (kilee)
			CII.CommInspSelectGroupCode,
			''                                                                                                                                                            AS MeasureResult,
			0.0 AS NumericMeasure,
			CIMH.TextMeasure AS TextMeasure,
			CISI.CommInspSelectItemCode,
			CISI.CommInspSelectItemValue,
			CISI.CommInspSelectResult,
			CASE WHEN ISNULL(CIMH.MeasureResult,'NG') = 'OK'              THEN CONVERT(BIT,1)		                                                                ELSE CONVERT(BIT,0)		   END AS CheckDisplay,			
		  --SCH.CIDHExtText03                                                                                                                                                                                                   AS  NG_Check,                  -- 2020.01.31  검사결과 추가 (원본백업)
		    CIDI.CommInspRemark                                                                                                                                                                                              AS  CommInspRemark,                   -- 2020.01.31  검사결과 추가

			--CASE	WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC'                                            THEN CONVERT(VARCHAR, CONVERT(NUMERIC(10,2), CIMH1.NumericMeasure))	
			--        WHEN CIMH1.MeasureResult = 0                                                                          THEN 'OK'
			--		WHEN CIMH1.MeasureResult = 1                                                                          THEN 'NG'                                                                                  			ELSE CIMH1.MeasureResult  END AS FirstMeasureValue,           -- 1번째측정값
			CASE	WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN CONVERT(VARCHAR, CONVERT(NUMERIC(10,2), CIMH1.NumericMeasure))	ELSE CIMH1.MeasureResult  END AS FirstMeasureValue,           -- 1번째측정값
			CASE	WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN CONVERT(VARCHAR, CONVERT(NUMERIC(10,2), CIMH2.NumericMeasure))	ELSE CIMH2.MeasureResult  END AS SecondMeasureValue,       -- 2번째측정값
			CASE	WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN CONVERT(VARCHAR, CONVERT(NUMERIC(10,2), CIMH3.NumericMeasure))	ELSE CIMH3.MeasureResult  END AS ThirdMeasureValue,          -- 2020.01.13 추가
			CASE	WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN CONVERT(VARCHAR, CONVERT(NUMERIC(10,2), CIMH4.NumericMeasure))	ELSE CIMH4.MeasureResult  END AS FourthMeasureValue,
			CASE	WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN CONVERT(VARCHAR, CONVERT(NUMERIC(10,2), CIMH5.NumericMeasure))	ELSE CIMH5.MeasureResult  END AS FifthMeasureValue,
			CASE	WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN CONVERT(VARCHAR, CONVERT(NUMERIC(10,2), CIMH6.NumericMeasure))	ELSE CIMH6.MeasureResult  END AS SixthMeasureValue,
			CASE	WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN CONVERT(VARCHAR, CONVERT(NUMERIC(10,2), CIMH7.NumericMeasure))	ELSE CIMH7.MeasureResult  END AS SeventhMeasureValue,
			CASE	WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN CONVERT(VARCHAR, CONVERT(NUMERIC(10,2), CIMH8.NumericMeasure))	ELSE CIMH8.MeasureResult  END AS EightMeasureValue,
			CASE	WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN CONVERT(VARCHAR, CONVERT(NUMERIC(10,2), CIMH9.NumericMeasure))	ELSE CIMH9.MeasureResult  END AS NineMeasureValue,
			CASE	WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN CONVERT(VARCHAR, CONVERT(NUMERIC(10,2), CIMH.NumericMeasure))	ELSE CIMH.MeasureResult	   END AS LastMeasureValue,            -- 최종측정값


			CASE WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN CONVERT(VARCHAR, CONVERT(NUMERIC(10,2), CIMH.NumericMeasure))	ELSE CIMH.MeasureResult	   END AS OldLastMeasureValue,
			--CASE WHEN CIMH1.MeasureResult = 0                THEN 'OK'  
			--       WHEN CIMH1.MeasureResult = 0                THEN 'NG'           ELSE SCH.CIDHExtText03  END                                                                                               AS CIDHExtText03,             -- 2020.01.20 OK/NG유무추가
			CIMH.CommInspMeasureNo,
			CIMH.MeasureSeq,
			''                                     AS DefectCode,
			CONVERT(BIT,0)                   AS IsHolding,
			CII.DisplayIndex
		--	, SCH.CIDHExtInt03   AS ProcessSteps   --2021.10.20 추가사항
		    , CIDI.ProcessSteps   AS ProcessSteps   --2021.10.25 추가사항
		

	FROM			
			STB_CommInspDocItem CIDI
			LEFT OUTER JOIN STB_CommInspItem CII				                            ON CII.CommInspItemCode = CIDI.CommInspItemCode
			LEFT OUTER JOIN VW_CommInspInputType VIEW_CIIT 				            ON VIEW_CIIT.CommInspInputType = CIDI.CommInspInputType
			LEFT OUTER JOIN SmartFramework_File.dbo.STB_AttachedFileMaster AFM		ON (AFM.FileID = CIDI.ImageFileID)
			LEFT OUTER JOIN (SELECT * FROM #MeasureTable WHERE MeasureSeq = 1 ) CIMH1 ON CIMH1.CommInspDocItemNo = CIDI.CommInspDocItemNo  
			LEFT OUTER JOIN (SELECT * FROM #MeasureTable WHERE MeasureSeq = 2 ) CIMH2 ON CIMH2.CommInspDocItemNo = CIDI.CommInspDocItemNo
			LEFT OUTER JOIN (SELECT * FROM #MeasureTable WHERE MeasureSeq = 3 ) CIMH3 ON CIMH3.CommInspDocItemNo = CIDI.CommInspDocItemNo       -- 2020.01.13 추가
			LEFT OUTER JOIN (SELECT * FROM #MeasureTable WHERE MeasureSeq = 4 ) CIMH4 ON CIMH4.CommInspDocItemNo = CIDI.CommInspDocItemNo
			LEFT OUTER JOIN (SELECT * FROM #MeasureTable WHERE MeasureSeq = 5 ) CIMH5 ON CIMH5.CommInspDocItemNo = CIDI.CommInspDocItemNo
			LEFT OUTER JOIN (SELECT * FROM #MeasureTable WHERE MeasureSeq = 6 ) CIMH6 ON CIMH6.CommInspDocItemNo = CIDI.CommInspDocItemNo
			LEFT OUTER JOIN (SELECT * FROM #MeasureTable WHERE MeasureSeq = 7 ) CIMH7 ON CIMH7.CommInspDocItemNo = CIDI.CommInspDocItemNo
			LEFT OUTER JOIN (SELECT * FROM #MeasureTable WHERE MeasureSeq = 8 ) CIMH8 ON CIMH8.CommInspDocItemNo = CIDI.CommInspDocItemNo
			LEFT OUTER JOIN (SELECT * FROM #MeasureTable WHERE MeasureSeq = 9 ) CIMH9 ON CIMH9.CommInspDocItemNo = CIDI.CommInspDocItemNo

			LEFT OUTER JOIN @MeasureTableMAX CIMH ON CIMH.CommInspDocItemNo = CIDI.CommInspDocItemNo			
			LEFT OUTER JOIN STB_CommInspSelectItem CISI WITH(NOLOCK)				ON CISI.CommInspSelectResult = CIMH.MeasureResult				AND CISI.CommInspSelectGroupCode = CII.CommInspSelectGroupCode
			LEFT OUTER JOIN STB_CommInspDocHistory SCH WITH(NOLOCK)				ON SCH.CommInspDocNo = CIDI.CommInspDocNo

	WHERE 1=1
	  AND CIDI.CommInspDocNo = @CommInspDocNo
	  AND (CII.CommInspItemGroup3 IS NULL OR CII.CommInspItemGroup3 LIKE '%' + @Size + '%')
	  AND (CII.DisplayIndex < 100)
	  AND (@IsExceptDestInsp = CONVERT(BIT, 0) OR (CII.CommInspItemCode NOT IN ('STRIPPING', 'LENGTHP'
	                                                                          , 'LENGTHM', 'THICKP'
																			  , 'THICKM', 'tP'
																			  , 'tM', 'WDecapInsp'))
		  )
	  
	ORDER BY CII.DisplayIndex

	DROP TABLE #MeasureTable
END