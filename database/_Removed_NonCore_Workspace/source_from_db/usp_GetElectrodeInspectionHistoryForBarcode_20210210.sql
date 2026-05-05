
-- =============================================================================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-05-13
-- Browsable : true
-- Group : 품질관리 > [C460] 전극공정검사(바코드) > Grid2 전극공정검사 get조회
-- Description:	공용검사이력조회 
-- Modified: 
				-- 2020.05.13 밀도 자동 계산 등을 위해 기존 usp_GetCommInspectionHistoryForBarcode를 변경함.
				-- 2020.06.29 전극 밀도스펙 표시 By Jackaroe #200629
				-- 2020.08.20 전극 비고 및 특이사항 항목추가 (구형규)
				-- 2020.09.22 전극구분(일반,패턴) 추가 (구형규) 

-- [프로시저실행문]  usp_GetElectrodeInspectionHistoryForBarcode 'kilee','Korean','ROUTE_ELECTRODE_QUALITY','VJKR1611601E23','','','','','',''
-- ===============================================================================================

CREATE PROCEDURE [dbo].[usp_GetElectrodeInspectionHistoryForBarcode_20210210]
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
			LEFT OUTER JOIN STB_ModelBasicInfo MBI		ON MM.MaterialName = MBI.ModelName
	WHERE 1=1
	    -- AND SI.Barcode = @Barcode                                                                                                                                                     -- 원본백업
		   AND SI.Barcode = @Barcode OR SI.Barcode = (SELECT NewBarcode  FROM STB_LotChangeMaterialHistory WHERE OldBarcode = @Barcode )            -- 2020.04.17 추가 (기종변경 바코드추가) 


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

	WHILE @cnt <= 9 
	
	BEGIN
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
								INNER JOIN STB_CommInspMeasureHist CMH								   ON CMH.CommInspDocItemNo = CIDI.CommInspDocItemNo										
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

	-- 최종 Select문 --------------------------------------------------------------------------------------------------------------
	SELECT A.Barcode
			  ,A.ControlNo
			  ,A.IsLoss
			  ,A.IsFinished
			  ,A.CommInspDocItemNo
			  ,A.CommInspDocNo
			  ,A.CommInspItemCode
			  ,A.CommInspItemName
			  ,A.CommInspUnit
			  ,A.CommInspItemDesc
			  ,A.CommInspInputType
			  ,A.CommInspInputTypeName
			  ,A.CommInspItemSpec
			  ,A.CommInspUpper
			  ,A.CommInspLower
			  ,A.ItemTargetQty
			  ,A.ItemQty
			  ,A.[FileName]
			  ,A.FileSize
			  ,A.FileData
			  ,A.CommInspRemark                 -- 검사결과
	 		  ,A.CommInspSelectGroupCode
			  ,A.MeasureResult
			  ,A.NumericMeasure
			  ,TextMeasure
			  ,CommInspSelectItemCode
			  ,CommInspSelectItemValue
			  ,CommInspSelectResult
			  ,A.CheckDisplay
			  ,A.NG_Check
			  ,A.FirstMeasureValue
			  ,A.SecondMeasureValue
			  ,A.ThirdMeasureValue
			  ,A.OldLastMeasureValue
			  ,A.CommInspMeasureNo
			  ,A.MeasureSeq
			  ,A.DefectCode
			  ,A.IsHolding
			  ,A.DisplayIndex
			  ,(CONVERT(NUMERIC(10, 5), A.FirstMeasureValue) + CONVERT(NUMERIC(10, 5), A.SecondMeasureValue) + CONVERT(NUMERIC(10, 5), A.ThirdMeasureValue)) / 3 AS ElectrodeSampleWeightAvgValue
			  ,dbo.fnGetElectrodeDensityNew (A.CommInspDocNo, A.FirstMeasureValue, A.SecondMeasureValue, A.ThirdMeasureValue, A.DisplayIndex)   AS ElectrodeDensityValue    -- 밀도
			  ,A.RollingDensityMin
			  ,A.RollingDensityMax
			  ,A.MaterialCode 
			  ,A.CIDHExtText02
			  , Case When A.ElectrodeDivision = 'N' Then '일반전극' 
			           When A.ElectrodeDivision = 'P' Then '패턴전극'  Else '기타' End  AS ElectrodeDivision     --전극구분
	  FROM (
					SELECT @Barcode    AS Barcode,
							@ControlNo AS ControlNo,
							@IsLoss      AS IsLoss,
							ISNULL(@IsFinished,0) AS IsFinished,
							CIDI.CommInspDocItemNo,
							CIDI.CommInspDocNo,
							CIDI.CommInspItemCode,
							CII.CommInspItemName,                               -- 점검항목명
							CIDI.CommInspUnit,
							CIDI.CommInspItemDesc,                                --- 한국어 항목설명 
							CIDI.CommInspInputType,
							VIEW_CIIT.CommInspInputTypeName,
							CIDI.CommInspItemSpec,                                 -- LSE 스펙하한값
							CIDI.CommInspUpper,
							CIDI.CommInspLower,
							CIDI.ItemTargetQty,                                        -- 검사시료수
							CASE WHEN ISNULL(CIDI.ItemQty,0)	>= CIDI.ItemTargetQty      THEN CIDI.ItemTargetQty 
									WHEN CIDI.ItemTargetQty = '20' AND CIDI.ItemQty <> '0' THEN '20'                      ELSE ISNULL(CIDI.ItemQty,0) END   AS ItemQty,     -- 2020.01.31 수정 - 현재검사수
							AFM.[FileName],
							AFM.FileSize,
							CONVERT(VARBINARY(MAX),NULL)                                                                AS FileData,
							CASE WHEN CII.DisplayIndex = 1 THEN SCH.CIDHExtText02 ELSE '' END                  AS CommInspRemark,               -- 2020.01.13 비고정보 수정 (kilee)
							CII.CommInspSelectGroupCode,
							''                                                                                                             AS MeasureResult,
							0.0 AS NumericMeasure,
							CIMH.TextMeasure AS TextMeasure,
							CISI.CommInspSelectItemCode,
							CISI.CommInspSelectItemValue,
							CISI.CommInspSelectResult,
							CASE WHEN ISNULL(CIMH.MeasureResult,'NG') = 'OK'              THEN CONVERT(BIT,1)		                                                                ELSE CONVERT(BIT,0)		   END AS CheckDisplay,			
							CIDI.CommInspRemark                                                                                                                                                                                              AS  NG_Check,                           -- 2020.01.31  검사결과 추가
							CASE	WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN CONVERT(VARCHAR, CONVERT(NUMERIC(10,3), CIMH1.NumericMeasure))	ELSE CIMH1.MeasureResult  END AS FirstMeasureValue,           -- 1번째측정값
							CASE	WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN CONVERT(VARCHAR, CONVERT(NUMERIC(10,3), CIMH2.NumericMeasure))	ELSE CIMH2.MeasureResult  END AS SecondMeasureValue,       -- 2번째측정값
							CASE	WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN CONVERT(VARCHAR, CONVERT(NUMERIC(10,3), CIMH3.NumericMeasure))	ELSE CIMH3.MeasureResult  END AS ThirdMeasureValue,          -- 2020.01.13 추가
							CASE WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN CONVERT(VARCHAR, CONVERT(NUMERIC(10,3), CIMH.NumericMeasure))	ELSE CIMH.MeasureResult	   END AS OldLastMeasureValue,
							CIMH.CommInspMeasureNo,
							CIMH.MeasureSeq,
							''                                     AS DefectCode,
							CONVERT(BIT,0)                   AS IsHolding,
							CII.DisplayIndex,
							EC.RollingDensityMin,
							EC.RollingDensityMax,
							SCH.MaterialCode  AS MaterialCode,                          -- 품명추가 2020-07-23
							SCH.CIDHExtText02  ,                                               -- 비고및 특이사항추가 2020-08-20 구형규
							SCH.ElectrodeDivision                                                --전극구분 추가
			FROM		                   STB_CommInspDocItem CIDI
					LEFT OUTER JOIN STB_CommInspItem CII				                            ON CII.CommInspItemCode = CIDI.CommInspItemCode
					LEFT OUTER JOIN VW_CommInspInputType VIEW_CIIT 				            ON VIEW_CIIT.CommInspInputType = CIDI.CommInspInputType
					LEFT OUTER JOIN SmartFramework_File.dbo.STB_AttachedFileMaster AFM		ON (AFM.FileID = CIDI.ImageFileID)
					LEFT OUTER JOIN (SELECT * FROM #MeasureTable WHERE MeasureSeq = 1 ) CIMH1 ON CIMH1.CommInspDocItemNo = CIDI.CommInspDocItemNo  
					LEFT OUTER JOIN (SELECT * FROM #MeasureTable WHERE MeasureSeq = 2 ) CIMH2 ON CIMH2.CommInspDocItemNo = CIDI.CommInspDocItemNo
					LEFT OUTER JOIN (SELECT * FROM #MeasureTable WHERE MeasureSeq = 3 ) CIMH3 ON CIMH3.CommInspDocItemNo = CIDI.CommInspDocItemNo       -- 2020.01.13 추가
					LEFT OUTER JOIN @MeasureTableMAX CIMH ON CIMH.CommInspDocItemNo = CIDI.CommInspDocItemNo			
					LEFT OUTER JOIN STB_CommInspSelectItem CISI WITH(NOLOCK)				ON CISI.CommInspSelectResult = CIMH.MeasureResult				AND CISI.CommInspSelectGroupCode = CII.CommInspSelectGroupCode
					LEFT OUTER JOIN STB_CommInspDocHistory SCH WITH(NOLOCK)				ON SCH.CommInspDocNo = CIDI.CommInspDocNo
					LEFT OUTER JOIN STB_ElectrodeCommon EC ON SCH.MaterialCode = EC.ProdCode
			WHERE 1=1
			  AND CIDI.CommInspDocNo = @CommInspDocNo
	) A
	GROUP BY A.Barcode,A.ControlNo,A.IsLoss,A.IsFinished,A.CommInspDocItemNo
				,A.CommInspDocNo,A.CommInspItemCode,A.CommInspItemName,A.CommInspUnit,A.CommInspItemDesc
				,A.CommInspInputType,A.CommInspInputTypeName,A.CommInspItemSpec,A.CommInspUpper,A.CommInspLower
				,A.ItemTargetQty,A.ItemQty,A.[FileName],A.FileSize,A.FileData
				,A.CommInspRemark,A.CommInspSelectGroupCode,A.MeasureResult,A.NumericMeasure,TextMeasure
				,CommInspSelectItemCode,CommInspSelectItemValue,CommInspSelectResult,A.CheckDisplay,A.NG_Check
				,A.FirstMeasureValue,A.SecondMeasureValue,A.ThirdMeasureValue,A.OldLastMeasureValue,A.CommInspMeasureNo
				,A.MeasureSeq,A.DefectCode,A.IsHolding,A.DisplayIndex,A.RollingDensityMin
				,A.RollingDensityMax, A.MaterialCode
				, A.CIDHExtText02
				, A.ElectrodeDivision  --추기
	ORDER BY A.DisplayIndex

	DROP TABLE #MeasureTable

END