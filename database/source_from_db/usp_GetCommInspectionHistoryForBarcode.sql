
-- ===================================================================================================
-- Author: Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-09-03
-- Browsable: true
-- Group: 품질관리 > 공용검사관리
-- Description:	공용검사이력조회 >  [C440] 공정검사(Lot No)화면 (Get)조회 프로시저 
-- Modified: 
--               2020.01.13 비고정보 변경 (kilee)
--               2022.01.13 검사항목추가 (RQ_StrippingAll) / 공정단계 필터 추가
-- [프로시저 실행문] :  usp_GetCommInspectionHistoryForBarcode   'kilee', 'Korean' ,'ROUTE_QUALITY' ,'VJMK103R850612', '', 'E-22', '' ,'' ,'' ,''   ,''   -- [VPC제품]
--                      exec    usp_GetCommInspectionHistoryForBarcode   'anhduy157', 'vi' ,'''' ,'ve260204-002', '', 'VE08', '' ,'' ,'' ,''   ,''         -- [VPC제품]
-- =========================================================================================================
CREATE PROCEDURE [dbo].[usp_GetCommInspectionHistoryForBarcode]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pCommInspTypeCode VARCHAR(50) = NULL,
						@pBarcode VARCHAR(50) = NULL,
						@pLineCode VARCHAR(20) = NULL,
						@pRouteCode VARCHAR(20) = NULL,
						@pMachineCode VARCHAR(20) = NULL,
						@pMoldNumber VARCHAR(50) = NULL,
						@pCategoryName VARCHAR(50) = NULL,
						@pCommInspRemark VARCHAR(50) = NULL,
						@pProcessSteps  VARCHAR(50) = NULL
AS

BEGIN
	SET NOCOUNT ON;

	DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
	DECLARE @CommInspTypeCode VARCHAR(50) = @pCommInspTypeCode
	DECLARE @Barcode VARCHAR(50) = @pBarcode
	DECLARE @LineCode VARCHAR(20) = ISNULL(@pLineCode,'')
	--DECLARE @RouteCode VARCHAR(20) = ISNULL(@pRouteCode,'')  -- 원본백업
	DECLARE @RouteCode VARCHAR(20) =  CASE WHEN ISNULL(@pRouteCode,'') = '' THEN '*' ELSE @pRouteCode END    -- 2022.02.10 추가

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

 -- DECLARE @ProcessSteps  VARCHAR(20) = @pProcessSteps   -- 2022.01.13 추가
	DECLARE @ProcessSteps VARCHAR(10) = CASE WHEN ISNULL(@pProcessSteps,'') = '' THEN '%' ELSE @pProcessSteps END    -- 2022.01.13 추가
	DECLARE @NewBarcode VARCHAR(50)

	SELECT @NewBarcode = NewBarcode
	  FROM STB_LotChangeMaterialHistory WITH(NOLOCK)
	 WHERE OldBarcode = @Barcode
	  
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
		MeasureSeq INT,
		MeasureDateTime DATETIME
	);
	
			--Mr Duy get CommInspTypeCode by Barcode
				DECLARE @getWorkCenterCode VARCHAR(20)
				DECLARE @getCompanyCode VARCHAR(20)
				
				select @getWorkCenterCode=POI.WorkCenterCode
				      ,@getCompanyCode=POI.CompanyCode
				  from STB_SetInfo SI
				  LEFT OUTER JOIN STB_ProductionOrderInfo POI		ON POI.PONo = SI.PONo
				 where SI.Barcode = @Barcode

				-- If products produced in Vietnam are inspected in Korea, they are classified based on workers.
				Declare @userCompanyCode VARCHAR(20)

				SELECT @userCompanyCode = CompanyCode 
				  FROM STB_UserInfo
				 WHERE UserID = @pProcessUserID

				IF @userCompanyCode = 'VVT' BEGIN
					if(@getWorkCenterCode='VVT_F1')
						begin
							set @CommInspTypeCode='ROUTE_TEST2'
						end
					else if(@getWorkCenterCode='VVT_F2')
						begin
							set @CommInspTypeCode='ROUTE_TEST2_BG'
						end
					else if(@getWorkCenterCode='VVT_F3')
						begin
							set @CommInspTypeCode='VE_ROUTE_TEST'
						end
					--else if(@getWorkCenterCode='VVT_F4')		-- Mr.Manh add 2026-02-20 for Bac Giang 2
					--	begin
					--		set @CommInspTypeCode='ROUTE_TEST_PCBA_BG2'
					--	end
				end
					--RAISERROR(@CommInspTypeCode,16,1)


			 -- Mr.Tung add Self-Inspection condition for VPC product on 2022-July-15
				if(@CompanyCode='VVT' and @CommInspTypeCode = 'ROUTE_TEST2'  and @MaterialCode LIKE 'LIVT%' and @getWorkCenterCode='VVT_F1') 
							SET  @CommInspTypeCode = 'ROUTE_TEST_VPC2'
				else if( @CommInspTypeCode = 'ROUTE_TEST2' and @MaterialCode LIKE 'LIVT%') begin
							EXEC SmartFramework.dbo.usp_GetAddonStringResource	@ProcessLanguage, N'^Không tồn tại hoặc thiếu loại hình kiểm tra hàng VPC.^', @ErrorMessage OUTPUT
							SET @ErrorMessage = @ErrorMessage + ' [%s]'
							RAISERROR(@ErrorMessage,16,1,@Barcode)
							RETURN
				end
			 -- Mr.Tung add Self-Inspection condition for VPC product on 2022-July-15

			 IF @CommInspTypeCode = 'MEA_ROUTE_QUALITY' AND @MaterialCode IN ('MAVTPF-010-4', 'MAVTPF-010-5') BEGIN
				set @CommInspTypeCode='MEA_ELECTRODE_ROUTE_INOCEL'
			 END


	SELECT @Size = CASE WHEN MBI.MBISizeW IN (22, 36) THEN 'L' ELSE 'SM' END
	  FROM STB_ModelBasicInfo MBI
	 WHERE ModelCode = (SELECT MaterialCode FROM STB_SetInfo WHERE Barcode = @Barcode OR Barcode = @NewBarcode)

	 -- 베트남 제품이 본사에서 검사되는 경우 때문에 CompanyCode와 WorkCenterCode를 STB_UserInfo에서 가져오도록 변경. 2022.09.24 By Jackaroe
	SELECT @CompanyCode = CompanyCode
	      ,@WorkCenterCode = WorkCenterCode
	  FROM STB_UserInfo
	 WHERE UserID = @pProcessUserID

	IF @CommInspTypeCode IN ('ROUTE_TEST_PS', 'ROUTE_QUALITY_PS') BEGIN
		SET @CompanyCode = 'VNT'
		SET @WorkCenterCode = 'VNT_F3'
	END

	-- 2024.10.18 완주2공장 자주검사 예외처리
	IF @CommInspTypeCode = 'ROUTE_TEST' AND @WorkCenterCode = 'VNT_F4'  BEGIN
		SET @CommInspTypeCode = 'ROUTE_TEST_WF2'
	END
	--RAISERROR(@CommInspTypeCode,16,1)
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
			LEFT OUTER JOIN STB_MaterialMaster MM			ON MM.MaterialCode = SI.MaterialCode
			LEFT OUTER JOIN STB_ModelBasicInfo MBI		    ON MM.MaterialCode = MBI.ModelCode

			--LEFT OUTER JOIN STB_CommInspItem CII ON CII.
	WHERE 1=1
	    -- AND SI.Barcode = @Barcode                                                                                                                                               -- 원본백업
		   AND SI.Barcode = @Barcode OR SI.Barcode = @NewBarcode    -- 2020.04.17 추가 (기종변경 바코드추가) 

	-- 크기에 상관없이 베트남이면 0
	IF @CompanyCode = 'VVT' 
	
	BEGIN
		SET @IsExceptDestInsp = CONVERT(BIT, 0)
	END

	
	IF ISNULL(@IsFinished,0) = 1 
	
		BEGIN

				EXEC SmartFramework.dbo.usp_GetAddonStringResource	@ProcessLanguage, '^이미 완료처리된 바코드입니다^', 	@ErrorMessage OUTPUT
				SET @ErrorMessage = @ErrorMessage + ' [%s]'
				RAISERROR(@ErrorMessage,16,1,@Barcode)
				RETURN
		END
	--declare @test varchar(10) =@IsHolding
	--raiserror(@test,16,1)
	IF ISNULL(@IsHolding,0) = 1 
	
		BEGIN

				EXEC SmartFramework.dbo.usp_GetAddonStringResource	@ProcessLanguage, '^이미 부적합처리된 바코드입니다^',	@ErrorMessage OUTPUT
				SET @ErrorMessage = @ErrorMessage + ' [%s]'
				RAISERROR(@ErrorMessage,16,1,@Barcode)
				RETURN
		END

	-- VPC제품때문에 화면을 두개로 하면서 체크하는 부분임!!
		IF @CommInspTypeCode = 'ROUTE_TEST' AND @MaterialCode LIKE 'LIVT%'    --#211007 ROUTE_TEST_VPC != LIVT-018 이거나 ROUTE_TEST == LIVT-018 인 경우를 체크함.
	
		BEGIN
			EXEC SmartFramework.dbo.usp_GetAddonStringResource	@ProcessLanguage, '^VPC제품입니다. [자주검사(VPC)] 화면에서 입력하세요.^', 	@ErrorMessage OUTPUT
					SET @ErrorMessage = @ErrorMessage + ' [%s]'
					RAISERROR(@ErrorMessage,16,1,@Barcode)
					RETURN
		END

		IF @CommInspTypeCode = 'ROUTE_TEST_VPC' AND @MaterialCode NOT LIKE 'LIVT%'
	
		BEGIN
			EXEC SmartFramework.dbo.usp_GetAddonStringResource	@ProcessLanguage, '^VPC제품이 아닙니다. 기존 자주검사 화면에서 입력하세요.^', @ErrorMessage OUTPUT
					SET @ErrorMessage = @ErrorMessage + ' [%s]'
					RAISERROR(@ErrorMessage,16,1,@Barcode)
					RETURN
		END
     -- VPC제품때문에 화면을 두개로 하면서 체크하는 부분임!!
	-- RAISERROR(@CommInspDocNo,16,1)

	IF ISNULL(@Barcode,'') <> '' AND ISNULL(@CommInspTypeCode,'') <> ''      -- Developer에서 화면 만들때는 생성하지 않게
	
	 BEGIN	
		--RAISERROR(@CommInspDocNo,16,1)
		--return

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

	-- STB_CommInspDocItem 정상 생성 여부 체크
	IF NOT EXISTS (SELECT 1 FROM STB_CommInspDocItem WHERE CommInspDocNo = @CommInspDocNo) BEGIN
		-- Delete CommInspDocHistory
		DELETE FROM STB_CommInspDocHistory WHERE CommInspDocNo = @CommInspDocNo

		-- Regenerator
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

	-- INSERT 부분 -----------
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
					FROM               STB_CommInspDocItem     CIDI
							INNER JOIN STB_CommInspMeasureHist CMH   ON	CMH.CommInspDocItemNo = CIDI.CommInspDocItemNo										
					WHERE 1=1
					  AND CIDI.CommInspDocNo = @CommInspDocNo
					GROUP BY	CMH.CommInspDocItemNo							
				)  MAXMS
				   LEFT OUTER JOIN STB_CommInspMeasureHist CIMH  ON CIMH.CommInspDocItemNo = MAXMS.CommInspDocItemNo	 AND CIMH.MeasureSeq = MAXMS.MeasureSeq


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
					A.MeasureSeq,
					A.MeasureDateTime
			FROM
					(
				 SELECT
					CIMH2.CommInspMeasureNo,
					CIMH2.CommInspDocItemNo,
					CIMH2.MeasureResult,
					CIMH2.NumericMeasure,
					CIMH2.TextMeasure,
					MAXMS2.MeasureSeq,
					CIMH2.MeasureDateTime
			FROM
					(
						SELECT
								CMH.CommInspDocItemNo,
								CMH.MeasureSeq							
						FROM
								STB_CommInspDocItem CIDI
								INNER JOIN STB_CommInspMeasureHist CMH   ON CMH.CommInspDocItemNo = CIDI.CommInspDocItemNo										
						WHERE   CIDI.CommInspDocNo = @CommInspDocNo
						  AND   CMH.MeasureSeq = @cnt
					) MAXMS2
					LEFT OUTER JOIN STB_CommInspMeasureHist CIMH2	  ON CIMH2.CommInspDocItemNo = MAXMS2.CommInspDocItemNo		 AND CIMH2.MeasureSeq = MAXMS2.MeasureSeq
			) A

		SET @cnt = @cnt + 1
	
	END
	-- Mr
	CREATE CLUSTERED INDEX IX_Temp_Measure_FastJoin ON #MeasureTable (CommInspDocItemNo, MeasureSeq);
	CREATE NONCLUSTERED INDEX XS_TEMPINDEX ON #MeasureTable (CommInspDocItemNo)
	CREATE NONCLUSTERED INDEX XS_TEMPINDEX2 ON #MeasureTable (MeasureSeq)


	--raiserror(@CommInspDocNo,16,1)
	-- //  [최종 Select문] ----------------------------------------------------------------------------------------------------------------------

	IF @userCompanyCode = 'VVT' OR @getCompanyCode = 'VVT' BEGIN
		SELECT
				@Barcode    AS Barcode,
				@ControlNo AS ControlNo,
				@IsLoss      AS IsLoss,
				ISNULL(@IsFinished,0) AS IsFinished,
				CIDI.CommInspDocItemNo,  --공용검사항목이력
				CIDI.CommInspDocNo,   --검사문서번호
				CIDI.CommInspItemCode,  
				CASE WHEN CIDI.CommInspItemCode = 'WAppInsp' AND @MaterialCode IN ('LIVT38-007', 'LIVT38-008', 'LIVT38-009', 'LIVT38-010', 'LIVT38-016')  
						THEN CII.CommInspItemName + '(권취소자 하단 전극 돌출 확인)'      ELSE CII.CommInspItemName END    AS CommInspItemName,                               -- 점검항목명 VPC 일부품목의 경우 점검항목명을 변경적용.
				CIDI.CommInspUnit,
				CIDI.CommInspItemDesc,                                -- 한국어 항목설명 
				CIDI.CommInspInputType,
				VIEW_CIIT.CommInspInputTypeName,
				CIDI.CommInspItemSpec,                                -- LSE 스펙하한값
				TRY_CAST(CIDI.CommInspUpper AS NUMERIC(10,2)) as CommInspUpper,   --chhuyển đổi sang dạng NUMERIC để có thể so sánh trong màn hình B597
				TRY_CAST(CIDI.CommInspLower as NUMERIC(10,2)) as CommInspLower,	--chhuyển đổi sang dạng NUMERIC để có thể so sánh trong màn hình B597
				CIDI.ItemTargetQty,                                       -- 검사시료수
				CASE WHEN ISNULL(CIDI.ItemQty,0)	>= CIDI.ItemTargetQty     THEN CIDI.ItemTargetQty 
					 when CIDI.CommInspItemCode in ('v_DryColor','v_SleveWrongD') and CIDI.ItemTargetQty=3  AND CIDI.ItemQty <> 3 then 3 --ad by Mr.Tung on 19-09-2022
					 WHEN CIDI.ItemTargetQty = '20' AND CIDI.ItemQty <> '0' THEN '20'
					 WHEN @CommInspTypeCode = 'ROUTE_QUALITY' AND VIEW_CIIT.CommInspInputTypeName <> 'NUMERIC' AND CIDI.ItemQty <> '0' THEN CIDI.ItemTargetQty -- 본사 공정검사이고, 검사항목유형이 수치가 아니면서 검사한 수량이 존재하면 현재검사 수에 검사시료수와 동일한 수량을 표시함. 2023.06.15 서동훈 프로 요청 By Jackaroe
					 ELSE ISNULL(CIDI.ItemQty,0) END   AS ItemQty,  -- 2020.01.31 수정 - 현재검사수
				--ISNULL(CIDI.ImageFileID,0) AS ImageFileID,
				AFM.[FileName],
				AFM.FileSize,
				CONVERT(VARBINARY(MAX),NULL)                                              AS FileData,
			 -- CIDI.CommInspRemark														     AS CommInspRemark ,  -- 원본백업
				CASE WHEN CII.DisplayIndex = 1 THEN SCH.CIDHExtText02 ELSE '' END AS CIDHExtText02,             -- 2020.01.13 비고정보 수정 (kilee)
				CII.CommInspSelectGroupCode,
				''                                       AS MeasureResult,
				0.0 AS NumericMeasure,
				CIMH.TextMeasure AS TextMeasure,
				CISI.CommInspSelectItemCode,
				CISI.CommInspSelectItemValue,
				CISI.CommInspSelectResult,
				CASE WHEN ISNULL(CIMH.MeasureResult,'NG') = 'OK'   THEN CONVERT(BIT,1)	  ELSE CONVERT(BIT,0)		   END AS CheckDisplay,			
			  --SCH.CIDHExtText03                                                                                                                     AS NG_Check,             -- 2020.01.31  검사결과 추가 (원본백업)
				CIDI.CommInspRemark                                                                                                                 AS  CommInspRemark,  -- 2020.01.31  검사결과 추가
				--CASE WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN CONVERT(VARCHAR, CONVERT(NUMERIC(10,2), CIMH1.NumericMeasure))	
				--       WHEN CIMH1.MeasureResult = 0                               THEN 'OK'
				--		 WHEN CIMH1.MeasureResult = 1                                THEN 'NG'  ELSE CIMH1.MeasureResult  END AS FirstMeasureValue,           -- 1번째측정값
				--CASE	WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN CONVERT(VARCHAR, CONVERT(NUMERIC(10,2), CIMH1.NumericMeasure))	ELSE CASE WHEN @CommInspTypeCode = 'ROUTE_TEST_PS' AND CIMH1.MeasureResult = '1' THEN 'OK' ELSE CIMH1.MeasureResult END  END AS FirstMeasureValue,           -- 1번째측정값

				-- may be someone changed it because UEI audit.... 2026.03.16
				/*
				CASE	WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN  
					case when  @userCompanyCode  = 'VVT'
						then CONVERT(NUMERIC(10,2), CIMH1.NumericMeasure)	
					ELSE 
						CONVERT(VARCHAR, CONVERT(NUMERIC(10,2), CIMH1.NumericMeasure))	
					END
					ELSE CASE WHEN @CommInspTypeCode = 'ROUTE_TEST_PS' AND CIMH1.MeasureResult = '1' THEN 'OK' ELSE CIMH1.MeasureResult END  END AS FirstMeasureValue, 

				CASE	WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN 
				case when  @userCompanyCode  = 'VVT'
						then CONVERT(NUMERIC(10,2), CIMH2.NumericMeasure)	
					ELSE 
						CONVERT(VARCHAR, CONVERT(NUMERIC(10,2), CIMH2.NumericMeasure))	
					END	ELSE CASE WHEN @CommInspTypeCode = 'ROUTE_TEST_PS' AND CIMH2.MeasureResult = '1' THEN 'OK' ELSE CIMH2.MeasureResult END  END AS SecondMeasureValue,       -- 2번째측정값
				CASE	WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN 
				case when  @userCompanyCode  = 'VVT'
						then CONVERT(NUMERIC(10,2), CIMH3.NumericMeasure)	
					ELSE 
						CONVERT(VARCHAR, CONVERT(NUMERIC(10,2), CIMH3.NumericMeasure))	
					END
				ELSE CASE WHEN @CommInspTypeCode = 'ROUTE_TEST_PS' AND CIMH3.MeasureResult = '1' THEN 'OK' ELSE CIMH3.MeasureResult END  END AS ThirdMeasureValue,          -- 2020.01.13 추가
				*/
				CASE	WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN  CONVERT(NUMERIC(10,2), CIMH1.NumericMeasure)	ELSE CASE WHEN @CommInspTypeCode = 'ROUTE_TEST_PS' AND CIMH1.MeasureResult = '1' THEN 'OK' ELSE CIMH1.MeasureResult END  END AS FirstMeasureValue,
				CASE	WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN  CONVERT(NUMERIC(10,2), CIMH2.NumericMeasure)	ELSE CASE WHEN @CommInspTypeCode = 'ROUTE_TEST_PS' AND CIMH2.MeasureResult = '1' THEN 'OK' ELSE CIMH2.MeasureResult END  END AS SecondMeasureValue,
				CASE	WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN  CONVERT(NUMERIC(10,2), CIMH3.NumericMeasure)	ELSE CASE WHEN @CommInspTypeCode = 'ROUTE_TEST_PS' AND CIMH3.MeasureResult = '1' THEN 'OK' ELSE CIMH3.MeasureResult END  END AS ThirdMeasureValue,
				CASE	WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN  CONVERT(NUMERIC(10,2), CIMH4.NumericMeasure)	ELSE CASE WHEN @CommInspTypeCode = 'ROUTE_TEST_PS' AND CIMH4.MeasureResult = '1' THEN 'OK' ELSE CIMH4.MeasureResult END  END AS FourthMeasureValue,
				CASE	WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN  CONVERT(NUMERIC(10,2), CIMH5.NumericMeasure)	ELSE CASE WHEN @CommInspTypeCode = 'ROUTE_TEST_PS' AND CIMH5.MeasureResult = '1' THEN 'OK' ELSE CIMH5.MeasureResult END  END AS FifthMeasureValue,
				CASE	WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN  CONVERT(NUMERIC(10,2), CIMH6.NumericMeasure)	ELSE CASE WHEN @CommInspTypeCode = 'ROUTE_TEST_PS' AND CIMH6.MeasureResult = '1' THEN 'OK' ELSE CIMH6.MeasureResult END  END AS SixthMeasureValue,
				CASE	WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN  CONVERT(NUMERIC(10,2), CIMH7.NumericMeasure)	ELSE CASE WHEN @CommInspTypeCode = 'ROUTE_TEST_PS' AND CIMH7.MeasureResult = '1' THEN 'OK' ELSE CIMH7.MeasureResult END  END AS SeventhMeasureValue,
				CASE	WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN  CONVERT(NUMERIC(10,2), CIMH8.NumericMeasure)	ELSE CASE WHEN @CommInspTypeCode = 'ROUTE_TEST_PS' AND CIMH8.MeasureResult = '1' THEN 'OK' ELSE CIMH8.MeasureResult END  END AS EightMeasureValue,
				CASE	WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN  CONVERT(NUMERIC(10,2), CIMH9.NumericMeasure)	ELSE CASE WHEN @CommInspTypeCode = 'ROUTE_TEST_PS' AND CIMH9.MeasureResult = '1' THEN 'OK' ELSE CIMH9.MeasureResult END  END AS NineMeasureValue,
				CASE	WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN  CONVERT(NUMERIC(10,2), CIMH.NumericMeasure )	ELSE CIMH.MeasureResult   END AS LastMeasureValue,            -- 최종측정값
					CASE 
				WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN  CONVERT(NUMERIC(10,2), CIMH11.NumericMeasure)
				WHEN CIDI.CommInspInputType = '2' and CIDI.ItemTargetQty>=11 then CIMH.MeasureResult end as Value11,
				CASE
				WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN  CONVERT(NUMERIC(10,2), CIMH12.NumericMeasure)
				 WHEN CIDI.CommInspInputType = '2' and CIDI.ItemTargetQty>=12 then CIMH.MeasureResult end as Value12,
				CASE 
				WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN  CONVERT(NUMERIC(10,2), CIMH13.NumericMeasure)
				WHEN CIDI.CommInspInputType = '2' and CIDI.ItemTargetQty>=13 then CIMH.MeasureResult end as Value13,
				CASE 
				WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN  CONVERT(NUMERIC(10,2), CIMH14.NumericMeasure)
				WHEN CIDI.CommInspInputType = '2' and CIDI.ItemTargetQty>=14 then CIMH.MeasureResult end as Value14,
				CASE 
				WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN  CONVERT(NUMERIC(10,2), CIMH15.NumericMeasure)
				WHEN CIDI.CommInspInputType = '2' and CIDI.ItemTargetQty>=15 then CIMH.MeasureResult end as Value15,
				CASE 
				WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN  CONVERT(NUMERIC(10,2), CIMH16.NumericMeasure)
				WHEN CIDI.CommInspInputType = '2' and CIDI.ItemTargetQty>=16 then CIMH.MeasureResult end as Value16,
				CASE 
				WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN  CONVERT(NUMERIC(10,2), CIMH17.NumericMeasure)
				WHEN CIDI.CommInspInputType = '2' and CIDI.ItemTargetQty>=17 then CIMH.MeasureResult end as Value17,
				CASE 
				WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN  CONVERT(NUMERIC(10,2), CIMH18.NumericMeasure)
				WHEN CIDI.CommInspInputType = '2' and CIDI.ItemTargetQty>=18 then CIMH.MeasureResult end as Value18,
				CASE 
				WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN  CONVERT(NUMERIC(10,2), CIMH19.NumericMeasure)
				WHEN CIDI.CommInspInputType = '2' and CIDI.ItemTargetQty>=19 then CIMH.MeasureResult end as Value19,
				CASE 
				WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN  CONVERT(NUMERIC(10,2), CIMH20.NumericMeasure)
				WHEN CIDI.CommInspInputType = '2' and CIDI.ItemTargetQty>=20 then CIMH.MeasureResult end as Value20,

				CASE WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN  CONVERT(NUMERIC(10,2), CIMH.NumericMeasure)	ELSE CIMH.MeasureResult   END AS OldLastMeasureValue,
				--CASE WHEN CIMH1.MeasureResult = 0                THEN 'OK'  
				--       WHEN CIMH1.MeasureResult = 0                THEN 'NG'           ELSE SCH.CIDHExtText03  END                                                                                               AS CIDHExtText03,             -- 2020.01.20 OK/NG유무추가
				CIMH.CommInspMeasureNo,
				CIMH.MeasureSeq,
				''                                     AS DefectCode,
				CONVERT(BIT,0)                   AS IsHolding,
				CII.DisplayIndex
			--	, SCH.CIDHExtInt03   AS ProcessSteps   --2021.10.20 추가사항
				, CIDI.ProcessSteps   AS ProcessSteps   --2021.10.25 추가사항
				, SCH.VPCMachineCode    -- VPC치수 측정 화면용으로 추가 #211207
				, MM.MachineName AS VPCMachineName
				, SCH.TrayNo
				, SCH.InspWorkerCode
				, PWI.WorkerName     AS InspWorkerName
				, CIMH1.MeasureDateTime AS InspDateTime
				, CASE WHEN CII.CommInspItemGroup1 = 'E-22' THEN '권취'
					   WHEN CII.CommInspItemGroup1 = 'E-24' THEN '조립'
					   WHEN CII.CommInspItemGroup1 = 'E-33' THEN '절곡' END AS RouteName
				,CIDI.RouteCode
				,RI.RouteName AS N'Công đoạn'
		FROM	STB_CommInspDocItem CIDI
				LEFT OUTER JOIN STB_CommInspItem CII ON CII.CommInspItemCode = CIDI.CommInspItemCode
				LEFT OUTER JOIN VW_CommInspInputType VIEW_CIIT ON VIEW_CIIT.CommInspInputType = CIDI.CommInspInputType
				LEFT OUTER JOIN SmartFramework_File.dbo.STB_AttachedFileMaster AFM	ON (AFM.FileID = CIDI.ImageFileID)
				LEFT OUTER JOIN (SELECT * FROM #MeasureTable WHERE MeasureSeq = 1 ) CIMH1 ON CIMH1.CommInspDocItemNo = CIDI.CommInspDocItemNo  
				LEFT OUTER JOIN (SELECT * FROM #MeasureTable WHERE MeasureSeq = 2 ) CIMH2 ON CIMH2.CommInspDocItemNo = CIDI.CommInspDocItemNo
				LEFT OUTER JOIN (SELECT * FROM #MeasureTable WHERE MeasureSeq = 3 ) CIMH3 ON CIMH3.CommInspDocItemNo = CIDI.CommInspDocItemNo       -- 2020.01.13 추가
				LEFT OUTER JOIN (SELECT * FROM #MeasureTable WHERE MeasureSeq = 4 ) CIMH4 ON CIMH4.CommInspDocItemNo = CIDI.CommInspDocItemNo
				LEFT OUTER JOIN (SELECT * FROM #MeasureTable WHERE MeasureSeq = 5 ) CIMH5 ON CIMH5.CommInspDocItemNo = CIDI.CommInspDocItemNo
				LEFT OUTER JOIN (SELECT * FROM #MeasureTable WHERE MeasureSeq = 6 ) CIMH6 ON CIMH6.CommInspDocItemNo = CIDI.CommInspDocItemNo
				LEFT OUTER JOIN (SELECT * FROM #MeasureTable WHERE MeasureSeq = 7 ) CIMH7 ON CIMH7.CommInspDocItemNo = CIDI.CommInspDocItemNo
				LEFT OUTER JOIN (SELECT * FROM #MeasureTable WHERE MeasureSeq = 8 ) CIMH8 ON CIMH8.CommInspDocItemNo = CIDI.CommInspDocItemNo
				LEFT OUTER JOIN (SELECT * FROM #MeasureTable WHERE MeasureSeq = 9 ) CIMH9 ON CIMH9.CommInspDocItemNo = CIDI.CommInspDocItemNo
				LEFT OUTER JOIN (SELECT * FROM #MeasureTable WHERE MeasureSeq = 10 ) CIMH10 ON CIMH10.CommInspDocItemNo = CIDI.CommInspDocItemNo
				LEFT OUTER JOIN (SELECT * FROM #MeasureTable WHERE MeasureSeq = 11 ) CIMH11 ON CIMH11.CommInspDocItemNo = CIDI.CommInspDocItemNo
				LEFT OUTER JOIN (SELECT * FROM #MeasureTable WHERE MeasureSeq = 12 ) CIMH12 ON CIMH12.CommInspDocItemNo = CIDI.CommInspDocItemNo
				LEFT OUTER JOIN (SELECT * FROM #MeasureTable WHERE MeasureSeq = 13 ) CIMH13 ON CIMH13.CommInspDocItemNo = CIDI.CommInspDocItemNo
				LEFT OUTER JOIN (SELECT * FROM #MeasureTable WHERE MeasureSeq = 14 ) CIMH14 ON CIMH14.CommInspDocItemNo = CIDI.CommInspDocItemNo
				LEFT OUTER JOIN (SELECT * FROM #MeasureTable WHERE MeasureSeq = 15 ) CIMH15 ON CIMH15.CommInspDocItemNo = CIDI.CommInspDocItemNo
				LEFT OUTER JOIN (SELECT * FROM #MeasureTable WHERE MeasureSeq = 16 ) CIMH16 ON CIMH16.CommInspDocItemNo = CIDI.CommInspDocItemNo
				LEFT OUTER JOIN (SELECT * FROM #MeasureTable WHERE MeasureSeq = 17 ) CIMH17 ON CIMH17.CommInspDocItemNo = CIDI.CommInspDocItemNo
				LEFT OUTER JOIN (SELECT * FROM #MeasureTable WHERE MeasureSeq = 18 ) CIMH18 ON CIMH18.CommInspDocItemNo = CIDI.CommInspDocItemNo
				LEFT OUTER JOIN (SELECT * FROM #MeasureTable WHERE MeasureSeq = 19 ) CIMH19 ON CIMH19.CommInspDocItemNo = CIDI.CommInspDocItemNo
				LEFT OUTER JOIN (SELECT * FROM #MeasureTable WHERE MeasureSeq = 20 ) CIMH20 ON CIMH20.CommInspDocItemNo = CIDI.CommInspDocItemNo
				LEFT OUTER JOIN @MeasureTableMAX CIMH                                                 ON CIMH.CommInspDocItemNo = CIDI.CommInspDocItemNo			
				LEFT OUTER JOIN STB_CommInspSelectItem CISI WITH(NOLOCK)				             ON CISI.CommInspSelectResult = CIMH.MeasureResult				AND CISI.CommInspSelectGroupCode = CII.CommInspSelectGroupCode
				LEFT OUTER JOIN STB_CommInspDocHistory SCH WITH(NOLOCK)				         ON SCH.CommInspDocNo = CIDI.CommInspDocNo
				LEFT OUTER JOIN STB_MachineMaster MM  WITH(NOLOCK)	                             ON MM.MachineCode = SCH.VPCMachineCode
				LEFT OUTER JOIN STB_ProdWorkerInfo PWI  WITH(NOLOCK)	                             ON PWI.WorkerCode = SCH.InspWorkerCode
				LEFT OUTER JOIN STB_RouteInfo RI WITH(NOLOCK)	ON RI.RouteCode = CIDI.RouteCode
		WHERE 1=1
		  AND CIDI.CommInspDocNo = @CommInspDocNo
		  AND (CII.CommInspItemGroup3 IS NULL OR CII.CommInspItemGroup3 LIKE '%' + @Size + '%')
		  AND (ISNULL(CII.DisplayIndex, 1) < 100)
		  AND (@IsExceptDestInsp = CONVERT(BIT, 0) OR (CII.CommInspItemCode NOT IN ('STRIPPING', 'LENGTHP', 'LENGTHM', 'THICKP', 'THICKM', 'tP', 'tM', 'WDecapInsp', 'RQV_V')))	  
		  AND (@RouteCode = '*' OR CII.RouteCode = @RouteCode)    -- 2022.02.10 추가사항

		ORDER BY CII.DisplayIndex
	END ELSE BEGIN
		SELECT
				@Barcode    AS Barcode,
				@ControlNo AS ControlNo,
				@IsLoss      AS IsLoss,
				ISNULL(@IsFinished,0) AS IsFinished,
				CIDI.CommInspDocItemNo,  --공용검사항목이력
				CIDI.CommInspDocNo,   --검사문서번호
				CIDI.CommInspItemCode,  
				CASE WHEN CIDI.CommInspItemCode = 'WAppInsp' AND @MaterialCode IN ('LIVT38-007', 'LIVT38-008', 'LIVT38-009', 'LIVT38-010', 'LIVT38-016')  
						THEN CII.CommInspItemName + '(권취소자 하단 전극 돌출 확인)'      ELSE CII.CommInspItemName END    AS CommInspItemName,                               -- 점검항목명 VPC 일부품목의 경우 점검항목명을 변경적용.
				CIDI.CommInspUnit,
				CIDI.CommInspItemDesc,                                -- 한국어 항목설명 
				CIDI.CommInspInputType,
				VIEW_CIIT.CommInspInputTypeName,
				CIDI.CommInspItemSpec,                                -- LSE 스펙하한값
				TRY_CAST(CIDI.CommInspUpper AS NUMERIC(10,2)) as CommInspUpper,   --chhuyển đổi sang dạng NUMERIC để có thể so sánh trong màn hình B597
				TRY_CAST(CIDI.CommInspLower as NUMERIC(10,2)) as CommInspLower,	--chhuyển đổi sang dạng NUMERIC để có thể so sánh trong màn hình B597
				CIDI.ItemTargetQty,                                       -- 검사시료수
				CASE WHEN ISNULL(CIDI.ItemQty,0)	>= CIDI.ItemTargetQty     THEN CIDI.ItemTargetQty 
					 when CIDI.CommInspItemCode in ('v_DryColor','v_SleveWrongD') and CIDI.ItemTargetQty=3  AND CIDI.ItemQty <> 3 then 3 --ad by Mr.Tung on 19-09-2022
					 WHEN CIDI.ItemTargetQty = '20' AND CIDI.ItemQty <> '0' THEN '20'
					 WHEN @CommInspTypeCode = 'ROUTE_QUALITY' AND VIEW_CIIT.CommInspInputTypeName <> 'NUMERIC' AND CIDI.ItemQty <> '0' THEN CIDI.ItemTargetQty -- 본사 공정검사이고, 검사항목유형이 수치가 아니면서 검사한 수량이 존재하면 현재검사 수에 검사시료수와 동일한 수량을 표시함. 2023.06.15 서동훈 프로 요청 By Jackaroe
					 ELSE ISNULL(CIDI.ItemQty,0) END   AS ItemQty,  -- 2020.01.31 수정 - 현재검사수
				--ISNULL(CIDI.ImageFileID,0) AS ImageFileID,
				AFM.[FileName],
				AFM.FileSize,
				CONVERT(VARBINARY(MAX),NULL)                                              AS FileData,
			 -- CIDI.CommInspRemark														     AS CommInspRemark ,  -- 원본백업
				CASE WHEN CII.DisplayIndex = 1 THEN SCH.CIDHExtText02 ELSE '' END AS CIDHExtText02,             -- 2020.01.13 비고정보 수정 (kilee)
				CII.CommInspSelectGroupCode,
				''                                       AS MeasureResult,
				0.0 AS NumericMeasure,
				CIMH.TextMeasure AS TextMeasure,
				CISI.CommInspSelectItemCode,
				CISI.CommInspSelectItemValue,
				CISI.CommInspSelectResult,
				CASE WHEN ISNULL(CIMH.MeasureResult,'NG') = 'OK'   THEN CONVERT(BIT,1)	  ELSE CONVERT(BIT,0)		   END AS CheckDisplay,			
			  --SCH.CIDHExtText03                                                                                                                     AS NG_Check,             -- 2020.01.31  검사결과 추가 (원본백업)
				CIDI.CommInspRemark                                                                                                                 AS  CommInspRemark,  -- 2020.01.31  검사결과 추가
				--CASE WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN CONVERT(VARCHAR, CONVERT(NUMERIC(10,2), CIMH1.NumericMeasure))	
				--       WHEN CIMH1.MeasureResult = 0                               THEN 'OK'
				--		 WHEN CIMH1.MeasureResult = 1                                THEN 'NG'  ELSE CIMH1.MeasureResult  END AS FirstMeasureValue,           -- 1번째측정값
				--CASE	WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN CONVERT(VARCHAR, CONVERT(NUMERIC(10,2), CIMH1.NumericMeasure))	ELSE CASE WHEN @CommInspTypeCode = 'ROUTE_TEST_PS' AND CIMH1.MeasureResult = '1' THEN 'OK' ELSE CIMH1.MeasureResult END  END AS FirstMeasureValue,           -- 1번째측정값

				-- may be someone changed it because UEI audit.... 2026.03.16
				/*
				CASE	WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN  
					case when  @userCompanyCode  = 'VVT'
						then CONVERT(NUMERIC(10,2), CIMH1.NumericMeasure)	
					ELSE 
						CONVERT(VARCHAR, CONVERT(NUMERIC(10,2), CIMH1.NumericMeasure))	
					END
					ELSE CASE WHEN @CommInspTypeCode = 'ROUTE_TEST_PS' AND CIMH1.MeasureResult = '1' THEN 'OK' ELSE CIMH1.MeasureResult END  END AS FirstMeasureValue, 

				CASE	WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN 
				case when  @userCompanyCode  = 'VVT'
						then CONVERT(NUMERIC(10,2), CIMH2.NumericMeasure)	
					ELSE 
						CONVERT(VARCHAR, CONVERT(NUMERIC(10,2), CIMH2.NumericMeasure))	
					END	ELSE CASE WHEN @CommInspTypeCode = 'ROUTE_TEST_PS' AND CIMH2.MeasureResult = '1' THEN 'OK' ELSE CIMH2.MeasureResult END  END AS SecondMeasureValue,       -- 2번째측정값
				CASE	WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN 
				case when  @userCompanyCode  = 'VVT'
						then CONVERT(NUMERIC(10,2), CIMH3.NumericMeasure)	
					ELSE 
						CONVERT(VARCHAR, CONVERT(NUMERIC(10,2), CIMH3.NumericMeasure))	
					END
				ELSE CASE WHEN @CommInspTypeCode = 'ROUTE_TEST_PS' AND CIMH3.MeasureResult = '1' THEN 'OK' ELSE CIMH3.MeasureResult END  END AS ThirdMeasureValue,          -- 2020.01.13 추가
				*/
				CASE	WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN  CONVERT(VARCHAR, CONVERT(NUMERIC(10,2), CIMH1.NumericMeasure))	ELSE CASE WHEN @CommInspTypeCode = 'ROUTE_TEST_PS' AND CIMH1.MeasureResult = '1' THEN 'OK' ELSE CIMH1.MeasureResult END  END AS FirstMeasureValue,
				CASE	WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN  CONVERT(VARCHAR, CONVERT(NUMERIC(10,2), CIMH2.NumericMeasure))	ELSE CASE WHEN @CommInspTypeCode = 'ROUTE_TEST_PS' AND CIMH2.MeasureResult = '1' THEN 'OK' ELSE CIMH2.MeasureResult END  END AS SecondMeasureValue,
				CASE	WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN  CONVERT(VARCHAR, CONVERT(NUMERIC(10,2), CIMH3.NumericMeasure))	ELSE CASE WHEN @CommInspTypeCode = 'ROUTE_TEST_PS' AND CIMH3.MeasureResult = '1' THEN 'OK' ELSE CIMH3.MeasureResult END  END AS ThirdMeasureValue,
				CASE	WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN  CONVERT(VARCHAR, CONVERT(NUMERIC(10,2), CIMH4.NumericMeasure))	ELSE CASE WHEN @CommInspTypeCode = 'ROUTE_TEST_PS' AND CIMH4.MeasureResult = '1' THEN 'OK' ELSE CIMH4.MeasureResult END  END AS FourthMeasureValue,
				CASE	WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN  CONVERT(VARCHAR, CONVERT(NUMERIC(10,2), CIMH5.NumericMeasure))	ELSE CASE WHEN @CommInspTypeCode = 'ROUTE_TEST_PS' AND CIMH5.MeasureResult = '1' THEN 'OK' ELSE CIMH5.MeasureResult END  END AS FifthMeasureValue,
				CASE	WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN  CONVERT(VARCHAR, CONVERT(NUMERIC(10,2), CIMH6.NumericMeasure))	ELSE CASE WHEN @CommInspTypeCode = 'ROUTE_TEST_PS' AND CIMH6.MeasureResult = '1' THEN 'OK' ELSE CIMH6.MeasureResult END  END AS SixthMeasureValue,
				CASE	WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN  CONVERT(VARCHAR, CONVERT(NUMERIC(10,2), CIMH7.NumericMeasure))	ELSE CASE WHEN @CommInspTypeCode = 'ROUTE_TEST_PS' AND CIMH7.MeasureResult = '1' THEN 'OK' ELSE CIMH7.MeasureResult END  END AS SeventhMeasureValue,
				CASE	WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN  CONVERT(VARCHAR, CONVERT(NUMERIC(10,2), CIMH8.NumericMeasure))	ELSE CASE WHEN @CommInspTypeCode = 'ROUTE_TEST_PS' AND CIMH8.MeasureResult = '1' THEN 'OK' ELSE CIMH8.MeasureResult END  END AS EightMeasureValue,
				CASE	WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN  CONVERT(VARCHAR, CONVERT(NUMERIC(10,2), CIMH9.NumericMeasure))	ELSE CASE WHEN @CommInspTypeCode = 'ROUTE_TEST_PS' AND CIMH9.MeasureResult = '1' THEN 'OK' ELSE CIMH9.MeasureResult END  END AS NineMeasureValue,
				CASE	WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN  CONVERT(VARCHAR, CONVERT(NUMERIC(10,2), CIMH.NumericMeasure ))	ELSE CIMH.MeasureResult   END AS LastMeasureValue,            -- 최종측정값
					CASE 
				WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN  CONVERT(VARCHAR, CONVERT(NUMERIC(10,2), CIMH11.NumericMeasure))	
				WHEN CIDI.CommInspInputType = '2' and CIDI.ItemTargetQty>=11 then CIMH.MeasureResult end as Value11,
				CASE
				WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN  CONVERT(VARCHAR, CONVERT(NUMERIC(10,2), CIMH12.NumericMeasure))
				 WHEN CIDI.CommInspInputType = '2' and CIDI.ItemTargetQty>=12 then CIMH.MeasureResult end as Value12,
				CASE 
				WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN CONVERT(VARCHAR, CONVERT(NUMERIC(10,2), CIMH13.NumericMeasure))
				WHEN CIDI.CommInspInputType = '2' and CIDI.ItemTargetQty>=13 then CIMH.MeasureResult end as Value13,
				CASE 
				WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN  CONVERT(VARCHAR, CONVERT(NUMERIC(10,2), CIMH14.NumericMeasure))
				WHEN CIDI.CommInspInputType = '2' and CIDI.ItemTargetQty>=14 then CIMH.MeasureResult end as Value14,
				CASE 
				WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN  CONVERT(VARCHAR, CONVERT(NUMERIC(10,2), CIMH15.NumericMeasure))
				WHEN CIDI.CommInspInputType = '2' and CIDI.ItemTargetQty>=15 then CIMH.MeasureResult end as Value15,
				CASE 
				WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN  CONVERT(VARCHAR, CONVERT(NUMERIC(10,2), CIMH16.NumericMeasure))
				WHEN CIDI.CommInspInputType = '2' and CIDI.ItemTargetQty>=16 then CIMH.MeasureResult end as Value16,
				CASE 
				WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN  CONVERT(VARCHAR, CONVERT(NUMERIC(10,2), CIMH17.NumericMeasure))
				WHEN CIDI.CommInspInputType = '2' and CIDI.ItemTargetQty>=17 then CIMH.MeasureResult end as Value17,
				CASE 
				WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN  CONVERT(VARCHAR, CONVERT(NUMERIC(10,2), CIMH18.NumericMeasure))
				WHEN CIDI.CommInspInputType = '2' and CIDI.ItemTargetQty>=18 then CIMH.MeasureResult end as Value18,
				CASE 
				WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN  CONVERT(VARCHAR, CONVERT(NUMERIC(10,2), CIMH19.NumericMeasure))
				WHEN CIDI.CommInspInputType = '2' and CIDI.ItemTargetQty>=19 then CIMH.MeasureResult end as Value19,
				CASE 
				WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN  CONVERT(VARCHAR, CONVERT(NUMERIC(10,2), CIMH20.NumericMeasure))
				WHEN CIDI.CommInspInputType = '2' and CIDI.ItemTargetQty>=20 then CIMH.MeasureResult end as Value20,

				CASE WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN  CONVERT(VARCHAR, CONVERT(NUMERIC(10,2), CIMH.NumericMeasure))	ELSE CIMH.MeasureResult   END AS OldLastMeasureValue,
				--CASE WHEN CIMH1.MeasureResult = 0                THEN 'OK'  
				--       WHEN CIMH1.MeasureResult = 0                THEN 'NG'           ELSE SCH.CIDHExtText03  END                                                                                               AS CIDHExtText03,             -- 2020.01.20 OK/NG유무추가
				CIMH.CommInspMeasureNo,
				CIMH.MeasureSeq,
				''                                     AS DefectCode,
				CONVERT(BIT,0)                   AS IsHolding,
				CII.DisplayIndex
			--	, SCH.CIDHExtInt03   AS ProcessSteps   --2021.10.20 추가사항
				, CIDI.ProcessSteps   AS ProcessSteps   --2021.10.25 추가사항
				, SCH.VPCMachineCode    -- VPC치수 측정 화면용으로 추가 #211207
				, MM.MachineName AS VPCMachineName
				, SCH.TrayNo
				, SCH.InspWorkerCode
				, PWI.WorkerName     AS InspWorkerName
				, CIMH1.MeasureDateTime AS InspDateTime
				, CASE WHEN CII.CommInspItemGroup1 = 'E-22' THEN '권취'
					   WHEN CII.CommInspItemGroup1 = 'E-24' THEN '조립'
					   WHEN CII.CommInspItemGroup1 = 'E-33' THEN '절곡' END AS RouteName
				,CIDI.RouteCode
				,RI.RouteName AS N'Công đoạn'
		FROM	STB_CommInspDocItem CIDI
				LEFT OUTER JOIN STB_CommInspItem CII ON CII.CommInspItemCode = CIDI.CommInspItemCode
				LEFT OUTER JOIN VW_CommInspInputType VIEW_CIIT ON VIEW_CIIT.CommInspInputType = CIDI.CommInspInputType
				LEFT OUTER JOIN SmartFramework_File.dbo.STB_AttachedFileMaster AFM	ON (AFM.FileID = CIDI.ImageFileID)
				LEFT OUTER JOIN (SELECT * FROM #MeasureTable WHERE MeasureSeq = 1 ) CIMH1 ON CIMH1.CommInspDocItemNo = CIDI.CommInspDocItemNo  
				LEFT OUTER JOIN (SELECT * FROM #MeasureTable WHERE MeasureSeq = 2 ) CIMH2 ON CIMH2.CommInspDocItemNo = CIDI.CommInspDocItemNo
				LEFT OUTER JOIN (SELECT * FROM #MeasureTable WHERE MeasureSeq = 3 ) CIMH3 ON CIMH3.CommInspDocItemNo = CIDI.CommInspDocItemNo       -- 2020.01.13 추가
				LEFT OUTER JOIN (SELECT * FROM #MeasureTable WHERE MeasureSeq = 4 ) CIMH4 ON CIMH4.CommInspDocItemNo = CIDI.CommInspDocItemNo
				LEFT OUTER JOIN (SELECT * FROM #MeasureTable WHERE MeasureSeq = 5 ) CIMH5 ON CIMH5.CommInspDocItemNo = CIDI.CommInspDocItemNo
				LEFT OUTER JOIN (SELECT * FROM #MeasureTable WHERE MeasureSeq = 6 ) CIMH6 ON CIMH6.CommInspDocItemNo = CIDI.CommInspDocItemNo
				LEFT OUTER JOIN (SELECT * FROM #MeasureTable WHERE MeasureSeq = 7 ) CIMH7 ON CIMH7.CommInspDocItemNo = CIDI.CommInspDocItemNo
				LEFT OUTER JOIN (SELECT * FROM #MeasureTable WHERE MeasureSeq = 8 ) CIMH8 ON CIMH8.CommInspDocItemNo = CIDI.CommInspDocItemNo
				LEFT OUTER JOIN (SELECT * FROM #MeasureTable WHERE MeasureSeq = 9 ) CIMH9 ON CIMH9.CommInspDocItemNo = CIDI.CommInspDocItemNo
				LEFT OUTER JOIN (SELECT * FROM #MeasureTable WHERE MeasureSeq = 10 ) CIMH10 ON CIMH10.CommInspDocItemNo = CIDI.CommInspDocItemNo
				LEFT OUTER JOIN (SELECT * FROM #MeasureTable WHERE MeasureSeq = 11 ) CIMH11 ON CIMH11.CommInspDocItemNo = CIDI.CommInspDocItemNo
				LEFT OUTER JOIN (SELECT * FROM #MeasureTable WHERE MeasureSeq = 12 ) CIMH12 ON CIMH12.CommInspDocItemNo = CIDI.CommInspDocItemNo
				LEFT OUTER JOIN (SELECT * FROM #MeasureTable WHERE MeasureSeq = 13 ) CIMH13 ON CIMH13.CommInspDocItemNo = CIDI.CommInspDocItemNo
				LEFT OUTER JOIN (SELECT * FROM #MeasureTable WHERE MeasureSeq = 14 ) CIMH14 ON CIMH14.CommInspDocItemNo = CIDI.CommInspDocItemNo
				LEFT OUTER JOIN (SELECT * FROM #MeasureTable WHERE MeasureSeq = 15 ) CIMH15 ON CIMH15.CommInspDocItemNo = CIDI.CommInspDocItemNo
				LEFT OUTER JOIN (SELECT * FROM #MeasureTable WHERE MeasureSeq = 16 ) CIMH16 ON CIMH16.CommInspDocItemNo = CIDI.CommInspDocItemNo
				LEFT OUTER JOIN (SELECT * FROM #MeasureTable WHERE MeasureSeq = 17 ) CIMH17 ON CIMH17.CommInspDocItemNo = CIDI.CommInspDocItemNo
				LEFT OUTER JOIN (SELECT * FROM #MeasureTable WHERE MeasureSeq = 18 ) CIMH18 ON CIMH18.CommInspDocItemNo = CIDI.CommInspDocItemNo
				LEFT OUTER JOIN (SELECT * FROM #MeasureTable WHERE MeasureSeq = 19 ) CIMH19 ON CIMH19.CommInspDocItemNo = CIDI.CommInspDocItemNo
				LEFT OUTER JOIN (SELECT * FROM #MeasureTable WHERE MeasureSeq = 20 ) CIMH20 ON CIMH20.CommInspDocItemNo = CIDI.CommInspDocItemNo
				LEFT OUTER JOIN @MeasureTableMAX CIMH                                                 ON CIMH.CommInspDocItemNo = CIDI.CommInspDocItemNo			
				LEFT OUTER JOIN STB_CommInspSelectItem CISI WITH(NOLOCK)				             ON CISI.CommInspSelectResult = CIMH.MeasureResult				AND CISI.CommInspSelectGroupCode = CII.CommInspSelectGroupCode
				LEFT OUTER JOIN STB_CommInspDocHistory SCH WITH(NOLOCK)				         ON SCH.CommInspDocNo = CIDI.CommInspDocNo
				LEFT OUTER JOIN STB_MachineMaster MM  WITH(NOLOCK)	                             ON MM.MachineCode = SCH.VPCMachineCode
				LEFT OUTER JOIN STB_ProdWorkerInfo PWI  WITH(NOLOCK)	                             ON PWI.WorkerCode = SCH.InspWorkerCode
				LEFT OUTER JOIN STB_RouteInfo RI WITH(NOLOCK)	ON RI.RouteCode = CIDI.RouteCode
		WHERE 1=1
		  AND CIDI.CommInspDocNo = @CommInspDocNo
		  AND (CII.CommInspItemGroup3 IS NULL OR CII.CommInspItemGroup3 LIKE '%' + @Size + '%')
		  AND (ISNULL(CII.DisplayIndex, 1) < 100)
		  AND (@IsExceptDestInsp = CONVERT(BIT, 0) OR (CII.CommInspItemCode NOT IN ('STRIPPING', 'LENGTHP', 'LENGTHM', 'THICKP', 'THICKM', 'tP', 'tM', 'WDecapInsp', 'RQV_V')))	  
		  AND (@RouteCode = '*' OR CII.RouteCode = @RouteCode)    -- 2022.02.10 추가사항

		ORDER BY CII.DisplayIndex
	END

	DROP TABLE #MeasureTable

END

