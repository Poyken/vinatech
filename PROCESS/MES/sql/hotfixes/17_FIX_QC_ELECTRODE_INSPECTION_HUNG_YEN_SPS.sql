-- =============================================
-- Hotfix ID: 17_FIX_QC_ELECTRODE_INSPECTION_HUNG_YEN_SPS
-- Target Object: usp_DoAddCommInspMeasureHistForBarcode_HY, usp_DoFinishCommInspDoc_HY, usp_DoFinishCommInspDoc_VNT_HY, usp_ElectrodeDivision_popup_HY, usp_DoLossElectrodeProcess_HY_iud, usp_GetElectrodeInspectionHistoryForBarcode_HY
-- Author: vanduc
-- Date: 2026-06-11
-- Description: Clone 6 stored procedures for QC Electrode Inspection screen C460 for Hung Yen (_HY).
-- =============================================

USE SmartFactoryV2;
GO

BEGIN TRAN;
GO

PRINT 'Starting Hotfix: 17_FIX_QC_ELECTRODE_INSPECTION_HUNG_YEN_SPS...';
GO
-- =========================================================
-- 1. Stored Procedure: usp_DoAddCommInspMeasureHistForBarcode_HY
-- =========================================================
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'usp_DoAddCommInspMeasureHistForBarcode_HY')
    DROP PROCEDURE [dbo].[usp_DoAddCommInspMeasureHistForBarcode_HY];
GO

-- =============================================
-- Author:		Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-09-03
-- Browsable : true
-- Group : 품질관리 > [C440]공정검사(Lot No) 조회
-- Description:	공용 검사이력을 추가 합니다.
-- Modified: 바코드 입력시
-- 2020.01.13  비고정보 업데이트 되도록 수정 (kilee)
-- 2020.01.13  
-- =============================================================
CREATE PROCEDURE [dbo].[usp_DoAddCommInspMeasureHistForBarcode_HY]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pCommInspDocNo VARCHAR(20),
						@pCommInspDocItemNo VARCHAR(20),
						@pTextMeasure VARCHAR(50),
						@pNumericMeasure NUMERIC(20,5),
						@pCheckDisplay BIT,
						@pInspWorkerCode VARCHAR(20),
						@pCIDHExtText02 VARCHAR(200) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	
    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@CommInspDocNo VARCHAR(20) = @pCommInspDocNo,
			@CommInspDocItemNo VARCHAR(20) = @pCommInspDocItemNo,
			@TextMeasure VARCHAR(50) = @pTextMeasure,
			@NumericMeasure NUMERIC(20,5) = @pNumericMeasure,
			@CheckDisplay BIT = @pCheckDisplay,
			@InspWorkerCode VARCHAR(20) = @pInspWorkerCode,
			@CIDHExtText02 VARCHAR(200) = @pCIDHExtText02

	DECLARE @Barcode VARCHAR(50)
	DECLARE @CommInspMeasureNo VARCHAR(20)
	DECLARE @IsAutoFinish BIT
	DECLARE @IsFinished BIT
	DECLARE @ErrorMessage NVARCHAR(500)

	SELECT
			@IsFinished = CIDH.IsFinished,
			@Barcode = SI.Barcode
	FROM
			STB_CommInspDocHistory CIDH
			LEFT OUTER JOIN STB_SetInfo SI				ON SI.ControlNo = CIDH.ProdNo
	WHERE
			CIDH.CommInspDocNo = @CommInspDocNo

	IF @IsFinished = 1 BEGIN
			EXEC SmartFramework.dbo.usp_GetAddonStringResource	@ProcessLanguage,
																'^이미 완료처리 되었습니다^',
																@ErrorMessage OUTPUT
			SET @ErrorMessage = @ErrorMessage + ' [%s]'
			RAISERROR(@ErrorMessage,16,1,@Barcode)
			RETURN
	END
	
	EXEC SmartFramework.dbo.usp_DoCreateSerial	'STB_CommInspMeasureHist', @CommInspMeasureNo OUTPUT

	INSERT INTO STB_CommInspMeasureHist
	(
		CommInspMeasureNo,
		CommInspDocItemNo,
		MeasureSeq,
		TextMeasure,		
		NumericMeasure,
		MeasureResult,
		MeasureDateTime,
		MeasureUserID,
		InspWorkerCode
	)
	VALUES
	(
		@CommInspMeasureNo,
		@CommInspDocItemNo,
		(
			SELECT ISNULL(MAX(MeasureSeq),0) + 1 FROM STB_CommInspMeasureHist CIMH WHERE CIMH.CommInspDocItemNo = @CommInspDocItemNo
		),
		@TextMeasure,
		ISNULL(@NumericMeasure, 0) ,                            -- 2020.01.22 추가사항
		CASE  WHEN @CheckDisplay = 1 THEN 'OK'
			ELSE 'NG' 	END,
		GETDATE(),
		@ProcessUserID,
		@InspWorkerCode
	)

	-- 2020.01.13 비고정보 추가 (kilee) Start   -->   Select CIDHExtText02,  * from STB_CommInspDocHistory where CommInspDocNo = '20191203000049'
		IF @CIDHExtText02 IS NOT NULL OR @CIDHExtText02 = ''
	
		BEGIN
			UPDATE  STB_CommInspDocHistory
					SET  CIDHExtText02 = @CIDHExtText02
				WHERE CommInspDocNo = @CommInspDocNo
		END
	-- 2020.01.13 비고정보 추가 (kilee) End

	SELECT
			@IsAutoFinish = CITI.IsAutoFinish
	FROM
			STB_CommInspDocHistory CIDH
			LEFT OUTER JOIN STB_CommInspTypeInfo CITI				ON CITI.CommInspTypeCode = CIDH.CommInspTypeCode
	WHERE
			CIDH.CommInspDocNo = @CommInspDocNo

	UPDATE STB_CommInspDocItem
	     SET ItemQty = (SELECT COUNT(*) FROM STB_CommInspMeasureHist WHERE CommInspDocItemNo = @CommInspDocItemNo)
	 WHERE CommInspDocItemNo = @CommInspDocItemNo
						
	IF @IsAutoFinish = 1 
	
	BEGIN
		IF NOT EXISTS (
						SELECT	1
						FROM
								(
									SELECT
											CIDI.CommInspDocItemNo,
											CIDI.ItemTargetQty,
											CASE 	WHEN CIDI.ItemTargetQty < COUNT(CIMH.MeasureResult) THEN CIDI.ItemTargetQty	ELSE COUNT(CIMH.MeasureResult)	END  AS GoodCount
									FROM 
														    STB_CommInspMeasureHist CIMH
											INNER JOIN STB_CommInspDocItem       CIDI		ON CIDI.CommInspDocItemNo = CIMH.CommInspDocItemNo
									WHERE 1=1
										AND CIDI.CommInspDocNo = @CommInspDocNo 
										AND	CIMH.MeasureResult = 'OK'
									GROUP BY
											CIDI.CommInspDocItemNo,
											CIDI.ItemTargetQty
								) CII

						WHERE
								CII.ItemTargetQty > CII.GoodCount

					) BEGIN
								UPDATE	STB_CommInspDocHistory
								SET
										IsFinished = 1,
										ChangeDateTime = GETDATE(),
										ChangeUserID = @ProcessUserID
								WHERE
										CommInspDocNo = @CommInspDocNo
					END
	END
END
GO

PRINT 'Procedure usp_DoAddCommInspMeasureHistForBarcode_HY created successfully.';
GO
-- =========================================================
-- 2. Stored Procedure: usp_DoFinishCommInspDoc_HY
-- =========================================================
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'usp_DoFinishCommInspDoc_HY')
    DROP PROCEDURE [dbo].[usp_DoFinishCommInspDoc_HY];
GO

-- =============================================
-- Author:		Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-09-09
-- Browsable : true
-- Group : 품질관리
-- Description:	공용 검사를 완료처리합니다
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoFinishCommInspDoc_HY]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCommInspDocNo VARCHAR(20) = NULL,
	@pIsCheckItem BIT = 1
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@CommInspDocNo VARCHAR(20) = @pCommInspDocNo,
			@IsCheckItem BIT = @pIsCheckItem,
			@ErrorMessage NVARCHAR(500)
	
	IF @IsCheckItem = 1 BEGIN
		IF EXISTS (
						SELECT	1
						FROM
						(
							SELECT
									CIDI.CommInspDocItemNo,
									CIDI.ItemTargetQty,
									CASE 
										WHEN CIDI.ItemTargetQty < COUNT(CIMH.MeasureResult) THEN CIDI.ItemTargetQty
										ELSE COUNT(CIMH.MeasureResult)
									END AS GoodCount
							FROM 
									STB_CommInspMeasureHist CIMH
									INNER JOIN STB_CommInspDocItem CIDI
										ON CIDI.CommInspDocItemNo = CIMH.CommInspDocItemNo
							WHERE
									CIDI.CommInspDocNo = @CommInspDocNo AND
									CIMH.MeasureResult = 'OK'
							GROUP BY
									CIDI.CommInspDocItemNo,
									CIDI.ItemTargetQty
						) CII
						WHERE
								CII.ItemTargetQty > CII.GoodCount
					) BEGIN
				EXEC SmartFramework.dbo.usp_GetAddonStringResource	@ProcessLanguage,
																	'^미검사 항목이 있습니다^',
																	@ErrorMessage OUTPUT
				SET @ErrorMessage = @ErrorMessage + ' [%s]'
				RAISERROR(@ErrorMessage,16,1,@CommInspDocNo)
				RETURN
		END
	END

	UPDATE	STB_CommInspDocHistory
	SET
			IsFinished = 1
	WHERE
			CommInspDocNo = @CommInspDocNo 
END
GO

PRINT 'Procedure usp_DoFinishCommInspDoc_HY created successfully.';
GO
-- =========================================================
-- 3. Stored Procedure: usp_DoFinishCommInspDoc_VNT_HY
-- =========================================================
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'usp_DoFinishCommInspDoc_VNT_HY')
    DROP PROCEDURE [dbo].[usp_DoFinishCommInspDoc_VNT_HY];
GO

-- =============================================
-- Author:		Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-09-09
-- Browsable : true
-- Group : 품질관리
-- Description:	공용 검사를 완료처리합니다
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoFinishCommInspDoc_VNT_HY]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCommInspDocNo VARCHAR(20) = NULL,
	@pIsCheckItem BIT = 1,
	@pIsHolding BIT = NULL,
	@pIsLoss BIT = NULL,
	@pIsFinished BIT = NULL,
	@pDefectCode VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@CommInspDocNo VARCHAR(20) = @pCommInspDocNo,
			@IsCheckItem BIT = @pIsCheckItem,
			@IsHolding BIT = ISNULL(@pIsHolding,0),
			@IsLoss BIT = ISNULL(@pIsLoss,0),
			@IsFinished BIT = ISNULL(@pIsFinished,0),
			@DefectCode VARCHAR(20) = ISNULL(@pDefectCode,'')

	DECLARE @ErrorMessage NVARCHAR(500)
	DECLARE @Barcode VARCHAR(50)
	DECLARE @IsCurrentHolding BIT
	DECLARE @IsCurrentLoss BIT
	DECLARE @IsCurrentFinished BIT
	DECLARE @LineCode VARCHAR(20)
	DECLARE @RouteCode VARCHAR(20)
	DECLARE @DefectQty NUMERIC(20,5)

	SELECT
			@IsCurrentHolding = ISNULL(SI.SIExtInt01,0),
			@IsCurrentLoss = SI.IsLoss,
			@IsCurrentFinished = CIDH.IsFinished,
			@Barcode = SI.Barcode,
			@LineCode = SI.InputLineCode
	FROM
			STB_CommInspDocHistory CIDH WITH(NOLOCK)
			INNER JOIN STB_SetInfo SI WITH(NOLOCK)
				ON SI.ControlNo = CIDH.ProdNo
	WHERE
			CIDH.CommInspDocNo = @CommInspDocNo
	
	IF @IsCurrentFinished = 1 BEGIN
			EXEC SmartFramework.dbo.usp_GetAddonStringResource	@ProcessLanguage,
																'^이미 완료처리 되었습니다^',
																@ErrorMessage OUTPUT
			SET @ErrorMessage = @ErrorMessage + ' [%s/%s]'
			RAISERROR(@ErrorMessage,16,1,@Barcode,@CommInspDocNo)
			RETURN
	END

	IF @IsCurrentHolding = 1 AND @IsHolding = 1 BEGIN
			EXEC SmartFramework.dbo.usp_GetAddonStringResource	@ProcessLanguage,
																'^이미 홀딩처리 되었습니다^',
																@ErrorMessage OUTPUT
			SET @ErrorMessage = @ErrorMessage + ' [%s/%s]'
			RAISERROR(@ErrorMessage,16,1,@Barcode,@CommInspDocNo)
			RETURN
	END

	IF @IsCurrentLoss = 1 BEGIN
			EXEC SmartFramework.dbo.usp_GetAddonStringResource	@ProcessLanguage,
																'^이미 폐기처리 되었습니다^',
																@ErrorMessage OUTPUT
			SET @ErrorMessage = @ErrorMessage + ' [%s/%s]'
			RAISERROR(@ErrorMessage,16,1,@Barcode,@CommInspDocNo)
			RETURN
	END

	IF @IsHolding = 1 BEGIN
			UPDATE	STB_SetInfo
			SET
					SIExtInt01 = 1
			WHERE
					Barcode = @Barcode

			-- 현재 바코드에 대한 공정재고 수량 구하기
			;WITH RouteStock AS
			(
				SELECT
						SI.Barcode,
						NPOR.RouteCode,
						SUM(PRH.ProdQty) - CASE WHEN ISNULL(NPOR.RouteCode,'') = '' THEN SUM(PRH.ProdQty) ELSE ISNULL(SUM(NPRH.ProdQty),0) END AS RouteStockQty
				FROM
						STB_ProdRouteHist PRH WITH(NOLOCK)
						LEFT OUTER JOIN STB_ProductionOrderRouting POR WITH(NOLOCK)
							ON PRH.PONo = POR.PONo AND
							PRH.RouteCode = POR.RouteCode
						LEFT OUTER JOIN STB_RouteInfo RI WITH(NOLOCK)
							ON RI.RouteCode = POR.RouteCode
						LEFT OUTER JOIN STB_ProductionOrderRouting NPOR WITH(NOLOCK)
							ON NPOR.PONo = POR.PONo AND
							NPOR.RouteIndex = POR.RouteIndex + 1
						LEFT OUTER JOIN STB_ProdRouteHist NPRH WITH(NOLOCK)
							ON NPRH.PONo = POR.PONo AND
							NPRH.ControlNo = PRH.ControlNo AND
							NPRH.RouteCode = NPOR.RouteCode
						LEFT OUTER JOIN STB_SetInfo SI WITH(NOLOCK)
							ON SI.ControlNo = PRH.ControlNo
				WHERE
						SI.Barcode = @Barcode
				GROUP BY
						SI.Barcode,
						NPOR.RouteCode
			), Defect AS	
			(
				SELECT
						SI.Barcode,
						SUM(DRI.DefectQty) AS DefectQty
				FROM
						STB_DefectRepairInfo DRI WITH(NOLOCK)
						INNER JOIN STB_SetInfo SI WITH(NOLOCK)
							ON SI.ControlNo = DRI.ControlNo
				WHERE
						SI.Barcode = @Barcode AND
						(DRI.RepairType IS NULL OR DRI.RepairType = 'NONE')
				GROUP BY
						SI.Barcode
			)
				SELECT
						@DefectQty = SUM(RS.RouteStockQty) - ISNULL(DF.DefectQty,0)	-- 미처리 불량수량은 빼준다
				FROM
						RouteStock RS
						LEFT OUTER JOIN Defect DF
							ON DF.Barcode = RS.Barcode
				GROUP BY
						RS.Barcode,
						DF.DefectQty
			
			-- 현재 바코드에 대한 마지막 실적입력 공정 구하기
			SELECT
					TOP 1
				 	@RouteCode = PRH.RouteCode
			FROM
					STB_ProdRouteHist PRH WITH(NOLOCK)
					INNER JOIN STB_SetInfo SI WITH(NOLOCK)
						ON SI.ControlNo = PRH.ControlNo
					INNER JOIN STB_ProductionOrderRouting POR WITH(NOLOCK)
						ON POR.PONo = SI.PONo AND
						POR.RouteCode = PRH.RouteCode
			WHERE
					SI.Barcode = @Barcode
			ORDER BY
					POR.RouteIndex DESC
					
			DECLARE @DefectSummaryNo VARCHAR(20)
			EXEC usp_DoProcessDefectRepairInfoByBarcode	@pProcessUserID = @pProcessUserID,
														@pProcessLanguage = @pProcessLanguage,
														@pLineCode = @LineCode,
														@pRouteCode = @RouteCode,
														@pBarcode = @Barcode,
														@pDefectCode = @DefectCode,
														@pDefectQty = @DefectQty,
														@pDefectSummaryNo = @DefectSummaryNo OUTPUT
			UPDATE	STB_DefectRepairInfo
			SET
					DRIExtText01 = @CommInspDocNo		-- 공정검사문서번호
			WHERE
					DefectSummaryNo = @DefectSummaryNo

	END ELSE IF @IsFinished = 1 BEGIN	--OR @IsLoss = 1 
			-- 폐기는 수리사에서
			--IF @IsLoss = 1 BEGIN
			--		UPDATE	STB_SetInfo
			--		SET
			--				IsLoss = 1
			--		WHERE
			--				Barcode = @Barcode
			--END

			EXEC usp_DoFinishCommInspDoc_HY	@pProcessUserID = @ProcessUserID,
											@pProcessLanguage = @ProcessLanguage,
											@pCommInspDocNo = @CommInspDocNo,
											@pIsCheckItem = @IsCheckItem

	END
END
GO

PRINT 'Procedure usp_DoFinishCommInspDoc_VNT_HY created successfully.';
GO
-- =========================================================
-- 4. Stored Procedure: usp_ElectrodeDivision_popup_HY
-- =========================================================
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'usp_ElectrodeDivision_popup_HY')
    DROP PROCEDURE [dbo].[usp_ElectrodeDivision_popup_HY];
GO

-- =============================================
-- Author: Kangs(yjyu@vina.co.kr)
-- Create date: 2020.09.18
-- Browsable : true
-- Group : 팝업
-- Description: 코드유형의 테이블을 쿼리하는 공용 프로시저
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_ElectrodeDivision_popup_HY]
								@pProcessUserID varchar(20),
								@pProcessLanguage varchar(20)
AS

BEGIN

	Select ItemCode
	       , Description
	 From SmartFramework.dbo.STB_BaseCode
  	 Where 1=1
	    And CodeGroup = 'ElectrodeDivision'
	
END
GO

PRINT 'Procedure usp_ElectrodeDivision_popup_HY created successfully.';
GO
-- =========================================================
-- 5. Stored Procedure: usp_DoLossElectrodeProcess_HY_iud
-- =========================================================
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'usp_DoLossElectrodeProcess_HY_iud')
    DROP PROCEDURE [dbo].[usp_DoLossElectrodeProcess_HY_iud];
GO

-- =============================================
-- Author: Kangs(kilee@vina.co.kr)
-- Create date: 2020-09-23
-- Browsable : true
-- Group : 품질관리 > [C460]전극공정검사 불합격 Button
-- Description:	전극공검 검사를 폐기처리합니다
-- Modified: 

-- [프로시저 실행문]  --   usp_DoLossElectrodeProcess_iud '','','',''
-- SELECT SIExtInt01, IsLoss, * FROM STB_SetInfo WHERE BARCODE ='VJKR1620001E17'
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoLossElectrodeProcess_HY_iud]
				@pProcessUserID VARCHAR(20),
				@pProcessLanguage VARCHAR(20),
				@pBarcode VARCHAR(50) = NULL,
				--@pCommInspDocNo VARCHAR(20),
				@pIsCheckItem BIT = NULL
AS

BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
				@ProcessLanguage VARCHAR(20) = @pProcessLanguage,
				@Barcode VARCHAR(50) = @pBarcode,
				@CommInspDocNo VARCHAR(20), --= @pCommInspDocNo,
				@IsCheckItem BIT = ISNULL(@pIsCheckItem,0)
			
	DECLARE @IsLoss BIT
	DECLARE @IsFinished BIT
	--DECLARE @Barcode VARCHAR(50)
	DECLARE @ErrorMessage NVARCHAR(500)
	DECLARE  @SIExtInt01 BIT
	DECLARE @NewBarcode VARCHAR(50)

	SELECT @NewBarcode = NewBarcode
	  FROM STB_LotChangeMaterialHistory
	 WHERE OldBarcode = @Barcode

	SELECT
			@CommInspDocNo = CIDH.CommInspDocNo
	FROM
								  STB_SetInfo SI			
			LEFT OUTER JOIN STB_CommInspDocHistory CIDH	ON 	CIDH.ProdNo = SI.ControlNo			
	WHERE 1=1	    
		   AND SI.Barcode = @Barcode OR SI.Barcode = @NewBarcode   

	SELECT
			@IsFinished = CIDH.IsFinished,
			@Barcode = SI.Barcode,
			@IsLoss = SI.IsLoss,
	        @SIExtInt01 = SIExtInt01
	FROM
			STB_CommInspDocHistory CIDH WITH(NOLOCK)
			INNER JOIN STB_SetInfo SI WITH(NOLOCK)
				ON SI.ControlNo = CIDH.ProdNo
	WHERE
			CIDH.CommInspDocNo = @CommInspDocNo
	
	--IF @IsFinished = 1 BEGIN
	--		EXEC SmartFramework.dbo.usp_GetAddonStringResource	@ProcessLanguage,
	--															'^이미 완료처리 되었습니다^',
	--															@ErrorMessage OUTPUT
	--		SET @ErrorMessage = @ErrorMessage + ' [%s/%s]'
	--		RAISERROR(@ErrorMessage,16,1,@Barcode,@CommInspDocNo)
	--		RETURN
	--END

	IF @SIExtInt01 = 1 
	
	BEGIN
			EXEC SmartFramework.dbo.usp_GetAddonStringResource	@ProcessLanguage,
																' ^폐기처리 되었습니다^',
																@ErrorMessage OUTPUT
			SET @ErrorMessage = @ErrorMessage + ' [%s/%s]'
			RAISERROR(@ErrorMessage,16,1,@Barcode,@CommInspDocNo)
			RETURN
	END


	UPDATE	STB_SetInfo
	SET
			SIExtInt01 = 1
			--,IsLoss = 1
	WHERE
			Barcode = @Barcode

	EXEC usp_DoFinishCommInspDoc_HY	@pProcessUserID = @ProcessUserID,
												@pProcessLanguage = @ProcessLanguage,
												@pCommInspDocNo = @CommInspDocNo,
												@pIsCheckItem = @IsCheckItem
END
GO

PRINT 'Procedure usp_DoLossElectrodeProcess_HY_iud created successfully.';
GO
-- =========================================================
-- 6. Stored Procedure: usp_GetElectrodeInspectionHistoryForBarcode_HY
-- =========================================================
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'usp_GetElectrodeInspectionHistoryForBarcode_HY')
    DROP PROCEDURE [dbo].[usp_GetElectrodeInspectionHistoryForBarcode_HY];
GO

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
				--Add  3 V_REQ_W0 by Mr.Tung on 06-July-2021
				-- 2021.11.29 데이터 형변환 (화면에서 조건부실행 오류로 인함 - 구형규)

-- [프로시저실행문 (2021.11.29) ]   usp_GetElectrodeInspectionHistoryForBarcode 'kilee','Korean','VVT','', 'VNT_F1','', '','VVOP0820001E07','','','','','','' 
-- ====================================================================================================================

CREATE PROCEDURE [dbo].[usp_GetElectrodeInspectionHistoryForBarcode_HY]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pCompanyCode VARCHAR(20) = NULL,
						@pCompanyName NVARCHAR(50) = NULL,
						@pWorkCenterCode VARCHAR(20) = NULL,
						@pWorkCenterName NVARCHAR(50) = NULL,
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

	SELECT @NewBarcode = NewBarcode  
	  FROM STB_LotChangeMaterialHistory 
	 WHERE OldBarcode = @Barcode


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

	Declare @MeasureTableWeight TABLE (
		Idx INT
	   ,NumericMeasure NUMERIC(20,5)
	)

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

	IF @pCompanyCode = 'VVT' BEGIN
		SET @CommInspTypeCode = 'ROUTE_ELECTRODE_QUALITY2'
	END
	ELSE
	BEGIN
		SET @CommInspTypeCode = 'ROUTE_ELECTRODE_QUALITY'
	END


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
		   AND SI.Barcode = @Barcode OR SI.Barcode = @NewBarcode            -- 2020.04.17 추가 (기종변경 바코드추가) 

	
	-- 화면에서 전달 받은 사업장코드와 작업장코드를 사용한다. 20250925 by Jackaroe
	IF @pCompanyCode IS NOT NULL BEGIN
		SET @CompanyCode = @pCompanyCode
	END

	IF @pWorkCenterCode IS NOT NULL BEGIN
		SET @WorkCenterCode = @pWorkCenterCode
	END


	-- 조회 대상이되는 Lot의 무게를 미리 구한다.
	INSERT INTO @MeasureTableWeight
	SELECT ROW_NUMBER() OVER(ORDER BY CIDI.CommInspItemCode)
		  ,CIMH.NumericMeasure
	  FROM STB_CommInspDocItem CIDI
	  LEFT OUTER JOIN STB_CommInspMeasureHist CIMH
	    ON CIDI.CommInspDocItemNo = CIMH.CommInspDocItemNo
	 WHERE CommInspDocNo = @CommInspDocNo
	   AND CIDI.CommInspItemCode IN ('REQ_W01', 'REQ_W02', 'REQ_W03','V_REQ_W01', 'V_REQ_W02', 'V_REQ_W03') --Add  3 V_REQ_W0 by Mr.Tung on 06-July-2021


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
			  ,A.NG_Check,
			  --A.FirstMeasureValue
			  
					CASE
					WHEN A.CommInspInputTypeName ='CHECK' and A.FirstMeasureValue =1 THEN 'OK'
					ELSE A.FirstMeasureValue
				END as FirstMeasureValue
			  ,A.SecondMeasureValue
			  ,A.ThirdMeasureValue
			  ,A.OldLastMeasureValue
			  ,A.CommInspMeasureNo
			  ,A.MeasureSeq
			  ,A.DefectCode
			  ,A.IsHolding
			  ,A.DisplayIndex
			  ,(CONVERT(NUMERIC(10, 5), A.FirstMeasureValue) + CONVERT(NUMERIC(10, 5), A.SecondMeasureValue) + CONVERT(NUMERIC(10, 5), A.ThirdMeasureValue)) / 3 AS ElectrodeSampleWeightAvgValue
			  ,dbo.fnGetElectrodeDensityNew (@Barcode, A.FirstMeasureValue, A.SecondMeasureValue, A.ThirdMeasureValue, ISNULL(MAX(MTW.NumericMeasure), 0))   AS ElectrodeDensityValue    -- 밀도
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
							--CIDI.CommInspUpper,   -- 원본백업
							--CIDI.CommInspLower,   -- 원본백업
							CONVERT(NUMERIC(10, 5), CIDI.CommInspUpper) AS CommInspUpper,    --2021.11.29 kilee수정 (구형규 요청)
							CONVERT(NUMERIC(10, 5), CIDI.CommInspLower) AS CommInspLower,     --2021.11.29 kilee수정 (구형규 요청)
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
	LEFT OUTER JOIN @MeasureTableWeight MTW
	  ON A.DisplayIndex = MTW.Idx
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
GO

PRINT 'Procedure usp_GetElectrodeInspectionHistoryForBarcode_HY created successfully.';
GO
COMMIT TRAN;
PRINT 'Transaction COMMIT successfully. Stored procedures created.';
-- ROLLBACK
GO