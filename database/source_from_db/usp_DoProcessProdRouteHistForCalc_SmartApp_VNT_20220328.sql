

-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-09-07
-- Browsable : true
-- Group : 현장용
-- Description: 불량수량을 계산하여 다음 공정으로 실적처리 합니다  [B530] 제품생산실적입력-실적완료 Button
-- Modified: 2020.01.28 진성검사불량수 추가

-- =============================================

CREATE PROCEDURE [dbo].[usp_DoProcessProdRouteHistForCalc_SmartApp_VNT_20220328]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pBarcode VARCHAR(50),
	@pRouteCode VARCHAR(20),
	@pWorkerCode VARCHAR(20) = NULL,
	@pWorkerList VARCHAR(200) = NULL,
	@pMachineCode VARCHAR(20) = NULL,
	@pMachineID VARCHAR(20) = NULL,
	@pMarkingLetter VARCHAR(50) = NULL,
	@pIntrinsicQty VARCHAR(20) = NULL,                        -- 2020.01.22 추가
	@DelayCode	VARCHAR(20) = NULL,
	@SIExtInt01 INT = NULL
AS

BEGIN
	SET NOCOUNT ON;

	DECLARE @Barcode VARCHAR(50) = @pBarcode
	DECLARE @RouteCode VARCHAR(20) = @pRouteCode
	DECLARE @WorkerCode VARCHAR(20) = ISNULL(@pWorkerCode,'')
	DECLARE @WorkerList VARCHAR(200) = ISNULL(@pWorkerList,'')
	DECLARE @MachineID VARCHAR(20) = ISNULL(@pMachineID,'')
	DECLARE @MachineCode VARCHAR(20) = ISNULL(@pMachineCode,'')
	DECLARE @MarkingLetter VARCHAR(50) = ISNULL(@pMarkingLetter,'')
	DECLARE @IntrinsicQty VARCHAR(20) = ISNULL(@pIntrinsicQty,'')                  -- 2020.01.22 추가                   

	DECLARE @PONo VARCHAR(20)
	DECLARE @AftRouteCode VARCHAR(20)
	DECLARE @ControlNo VARCHAR(20)
	DECLARE @LineCode VARCHAR(20)
	DECLARE @DefectQty NUMERIC(20,5)
	DECLARE @ProdQty NUMERIC(20,5)
	DECLARE @LotQty NUMERIC(20,5)
	DECLARE @IsInputRoute BIT
	DECLARE @IsHolding BIT
	DECLARE @IsOutputRoute BIT
	DECLARE @ErrorMessage NVARCHAR(500)
	DECLARE @PlanLineCode VARCHAR(20)
	DECLARE @DPPExtText01 NVARCHAR(100)
	DECLARE @RouteIndex INT
	DECLARE @RouteName NVARCHAR(200)
	DECLARE @ErrorMsg NVARCHAR(200)
	DECLARE @NextRouteCode VARCHAR(20)
	DECLARE @AftProdQty NUMERIC(20,5)
	-- STB_ProdRouteWorkerHist 업데이트용 ProdRouteHistNo
	DECLARE @ProdRouteHistNo VARCHAR(20)
	DECLARE @CompanyCode VARCHAR(20)

	-- 자주검사 입력완료 확인
	DECLARE @IsSelfInspectionFinish BIT


	SELECT
			@DPPExtText01 = DPP.DPPExtText01
		   ,@ControlNo = SI.ControlNo -- #220303 By Jackaroe
	FROM
			STB_SetInfo SI WITH(NOLOCK)
			INNER JOIN STB_DayProdPlan DPP WITH(NOLOCK)				ON DPP.DayPlanNo = SI.DayPlanNo
	WHERE
			SI.Barcode = @Barcode

	IF ISNULL(@DPPExtText01,'') = '1' 
	   BEGIN
			EXEC usp_RaiseLocalizedError @pProcessLanguage, '마감처리된 Lot입니다'
			RETURN
	  END

	-- 실적 처리 전 중간실적을 삭제한다. #220303 By Jackaroe
	DELETE 
	  FROM STB_InterimProdQtyInfo 
	 WHERE ControlNo = @ControlNo
	   AND RouteCode = @RouteCode

	


	-- 공정별 자주검사 완료여부 체크. 주영진 차장 요청. 2019.11.06 By Jackaroe
	/*
	IF @RouteCode IN ('E-22', 'E-24') 
			BEGIN
				exec usp_IsSelfInspectionFinish @pProcessUserID
											  , @pProcessLanguage
											  , 'ROUTE_TEST'
											  , @RouteCode
											  , @Barcode
											  , @IsSelfInspectionFinish OUTPUT

			--	IF @IsSelfInspectionFinish = 0

			--	BEGIN
			--		--EXEC usp_RaiseLocalizedError @pProcessLanguage, '^자주검사에 누락된 항목이 있습니다.^'
			--		--RETURN
			--	END

			  --- 진성불량수 추가부분
				--IF @IntrinsicQty IS NULL or @IntrinsicQty = ''				
				--BEGIN
				--		EXEC usp_RaiseLocalizedError @pProcessLanguage,'진성불량수가 입력되지 않았습니다.'
				--		RETURN
				--END



			END
	*/

	-- 다음공정 가져오기
	SELECT
			TOP 1
			@AftRouteCode = APOR.RouteCode,
			@IsOutputRoute = APOR.IsOutputRoute,
			@PONo = APOR.PONo,
			@ControlNo = SI.ControlNo,
			@LineCode = SI.InputLineCode,
			@LotQty = SI.ProdQty,
			@IsInputRoute = POR.IsInputRoute,
			@PlanLineCode = DPP.LineCode,
			@RouteIndex = POR.RouteIndex
	FROM
			STB_SetInfo SI WITH(NOLOCK)
			INNER JOIN STB_ProductionOrderRouting  POR WITH(NOLOCK)				ON POR.PONo = SI.PONo              AND				POR.RouteCode = @RouteCode
			INNER JOIN STB_ProductionOrderRouting  APOR WITH(NOLOCK)				ON APOR.PONo = SI.PONo            AND				APOR.RouteIndex > POR.RouteIndex
			INNER JOIN STB_DayProdPlan                 DPP WITH(NOLOCK)			    ON DPP.DayPlanNo = SI.DayPlanNo
	WHERE
			SI.Barcode = @Barcode
	ORDER BY
			APOR.RouteIndex


-- 일괄등록 금지! 마지막 등록 시간 기준 20분 이후 실적등록 가능 2021. 10. 26 SJC
	SELECT @CompanyCode = CompanyCode 
	  FROM STB_RouteInfo
	 WHERE RouteCode = @RouteCode

	SELECT @SIExtInt01 = SIExtInt01
	  FROM STB_SetInfo
	 WHERE Barcode = @Barcode

	IF @CompanyCode = 'VNT' AND @SIExtInt01 = Null AND @RouteIndex > 1 AND @RouteCode <> 'E-25' AND @RouteCode <> 'E-23'
		BEGIN
			DECLARE @TIME Varchar(2)

			SELECT @TIME = B.Time
			  FROM (
					SELECT CASE WHEN DATEDIFF(Mi, A.LastTime, GETDATE()) > 20 THEN 'OK' ELSE 'NG' END TIME
					FROM (
							SELECT TOP 1 PRH.ProdDateTime LastTime
							  FROM STB_SetInfo SI
							 INNER JOIN STB_ProdRouteHist PRH ON SI.ControlNo = PRH.ControlNo
							 WHERE SI.Barcode = @Barcode
							 ORDER BY PRH.ProdRouteHistNo Desc
						  ) A
					) B

			IF @TIME = 'NG' 
			   BEGIN
					EXEC usp_RaiseLocalizedError @pProcessLanguage, '마지막 실적 등록 후 20분 이후에 다음 공정 실적 등록이 가능합니다.'
					RETURN
			   END
		END
	-- 일괄등록 금지! 마지막 등록 시간 기준 20분 이후 실적등록 가능 2021. 10. 26 SJC

	-- 지연등록시 사유입력 기능 추가
	--IF @CompanyCode = 'VNT' AND @RouteCode >=  'E-25'--슬리빙 공정 실적등록시 커링 입력시간 비교
	--	BEGIN
	--		SELECT @TIME = B.Time
	--		  FROM (
	--				SELECT CASE WHEN DATEDIFF(Mi, A.LastTime, GETDATE()) > 180 THEN 'NG' ELSE 'OK' END TIME
	--				FROM (
	--						SELECT TOP 1 PRH.ProdDateTime LastTime
	--						  FROM STB_SetInfo SI
	--						 INNER JOIN STB_ProdRouteHist PRH ON SI.ControlNo = PRH.ControlNo
	--						 WHERE SI.Barcode = @Barcode
	--						 ORDER BY PRH.ProdRouteHistNo Desc
	--					  ) A
	--				) B

	--		IF @TIME = 'NG' AND (@DelayCode = '' OR @DelayCode IS NULL)
	--		   BEGIN
	--				EXEC usp_RaiseLocalizedError @pProcessLanguage, '공정 실적 등록 후 180분 이상 지연 시, 지연 사유를 입력해야 합니다.'
	--				RETURN
	--		   END
	--	END
		--	지연사유 입력 종료

		--- For Vietnam Bending Model, Add by Mr.Tung on  26-04-2021
	if(@routecode='V-33')
			begin

				SELECT
				TOP 1
						@AftRouteCode = APOR.RouteCode,
						@IsOutputRoute = APOR.IsOutputRoute,
						@PONo = APOR.PONo,
						@ControlNo = SI.ControlNo,
						@LineCode = SI.InputLineCode,
						@LotQty = SI.ProdQty,
						@IsInputRoute = POR.IsInputRoute,
						@PlanLineCode = DPP.LineCode,
						@RouteIndex = POR.RouteIndex
				FROM
						STB_SetInfo SI WITH(NOLOCK)
						INNER JOIN STB_ProductionOrderRouting  POR WITH(NOLOCK)				
										ON POR.PONo = SI.PONo              AND				POR.RouteCode = @RouteCode
						INNER JOIN STB_ProductionOrderRouting  APOR WITH(NOLOCK)				
										ON APOR.PONo = SI.PONo            AND				APOR.RouteIndex >= POR.RouteIndex  ---add equals sign
						INNER JOIN STB_DayProdPlan                 DPP WITH(NOLOCK)			    ON DPP.DayPlanNo = SI.DayPlanNo
				WHERE
						SI.Barcode = @Barcode
				ORDER BY
						APOR.RouteIndex	
	end




	IF ISNULL(@PONo,'') = ''
		BEGIN
				EXEC usp_RaiseLocalizedError @pProcessLanguage,'Routing에 없는 공정이거나 마지막공정입니다'
				RETURN
		END

	IF ISNULL(@IsHolding,0) = 1 BEGIN
			EXEC SmartFramework.dbo.usp_GetAddonStringResource	@pProcessLanguage,
																					'^공정검사 불합격 제품입니다^',
																					@ErrorMessage OUTPUT
			SET @ErrorMessage = @ErrorMessage + ' [%s]'
			RAISERROR(@ErrorMessage,16,1,@Barcode)
			RETURN
	END

	-- 이 곳에서 실적을 구하면, 투입공정인 경우 다음 공정의 투입수량이 계산되지 않는다. 아래로 이동함. 2019.04.02 By Jackaroe
	---- 현공정 실적 수량 구하기
	--SELECT
	--		@ProdQty = SUM(PRH.ProdQty)
	--FROM
	--		STB_ProdRouteHist PRH WITH(NOLOCK)
	--WHERE
	--		PRH.ControlNo = @ControlNo AND
	--		PRH.RouteCode = @RouteCode

	-- 현공정 불량수량 구하기
	SELECT
			@DefectQty = SUM(DRI.DefectQty)
	FROM
			STB_DefectRepairInfo DRI
	WHERE
			DRI.ControlNo = @ControlNo AND
			DRI.FindRouteCode = @RouteCode AND
			DRI.RepairType NOT IN ('MISSING', 'FINISH')                                -- 2019.08.23 수리완료제품도 제외 

	IF ISNULL(@IsInputRoute,0) = 1 
	    BEGIN		-- 투입공정이면
			SET @LineCode = @PlanLineCode

			EXEC usp_DoProcessProdRouteHist_VNT	@pProcessUserID = @pProcessUserID,
																@pProcessLanguage = @pProcessLanguage,
																@pBarcode = @pBarcode,
																@pLineCode = @LineCode,
																@pRouteCode = @RouteCode,
																@pWorkerCode = @WorkerCode,
																@pProdQty = @LotQty,
																@pMachineCode = @MachineCode,
																@pMachineID = @MachineID
			IF @WorkerList <> '' 
			   BEGIN		-- 작업자가 여러명일경우
					SELECT
							TOP 1
							@ProdRouteHistNo = PRH.ProdRouteHistNo
					FROM
							STB_ProdRouteHist PRH WITH(NOLOCK)
					WHERE
							PRH.ControlNo = @ControlNo AND
							PRH.RouteCode = @RouteCode
					ORDER BY
							PRH.ProdDateTime DESC

					EXEC usp_DoAddProdRouteHistByWorkerList	@pProcessUserID = @pProcessUserID,
																			@pProcessLanguage = @pProcessLanguage,
																			@pProdRouteHistNo = @ProdRouteHistNo,
																			@pWorkerCode = @WorkerList
			  END
	END

	-- 투입공정인 경우를 감안하여 실적처리 후 수량을 구함.
	-- 현공정 실적 수량 구하기
	SELECT
			@ProdQty = SUM(PRH.ProdQty)
	FROM
			STB_ProdRouteHist PRH
	WHERE
			PRH.ControlNo = @ControlNo AND
			PRH.RouteCode = @RouteCode


	IF ISNULL(@ProdQty,0) <= 0
	BEGIN
			SELECT
					TOP 1
					@RouteName = RI.RouteName
			FROM
					STB_ProductionOrderRouting POR
					LEFT OUTER JOIN STB_RouteInfo RI
						ON RI.RouteCode = POR.RouteCode
			WHERE
					POR.PONo = @PONo AND
					POR.RouteIndex < @RouteIndex
			ORDER BY
					POR.RouteIndex DESC

			SET @ErrorMsg = @RouteName + @RouteCode + ' 공정에서 실적을 입력하지 않았습니다'
			EXEC usp_RaiseLocalizedError @pProcessLanguage,@ErrorMsg
			RETURN
	END

	SELECT
			@AftProdQty = (PRH.ProdQty)
	FROM
			STB_ProdRouteHist PRH
	WHERE
			PRH.ControlNo = @ControlNo AND
			PRH.RouteCode = @AftRouteCode

	-- 다음공정 실적처리가 되어있으면 현공정은 실적처리 완료로 본다
	IF ISNULL(@AftProdQty,0) <> 0
	BEGIN
			EXEC usp_RaiseLocalizedError @pProcessLanguage,'이미 실적처리 완료한 공정입니다'
			RETURN
	END
			
	-- 다음 공정이 마지막 공정이 아니면
	IF ISNULL(@IsOutputRoute,0) = 0 
	    BEGIN
			SET @ProdQty = ISNULL(@ProdQty, 0) - ISNULL(@DefectQty,0)

			EXEC usp_DoProcessProdRouteHist_VNT	@pProcessUserID = @pProcessUserID,
												@pProcessLanguage = @pProcessLanguage,
												@pBarcode = @pBarcode,
												@pLineCode = @LineCode,
												@pRouteCode = @AftRouteCode,
												@pWorkerCode = @WorkerCode,
												@pProdQty = @ProdQty,
												@pMachineCode = @MachineCode,
												@pMachineID = @MachineID

			SELECT
					@AftProdQty = SUM(PRH.ProdQty)
			FROM
					STB_ProdRouteHist PRH
			WHERE
					PRH.ControlNo = @ControlNo AND
					PRH.RouteCode = @AftRouteCode

			IF ISNULL(@AftProdQty,0) = 0
				BEGIN
						EXEC usp_RaiseLocalizedError @pProcessLanguage,'실적처리 불가!'
						RETURN
				END
	
				IF @WorkerList <> '' 
				   BEGIN		-- 작업자가 여러명일경우
						SELECT
								TOP 1
								@ProdRouteHistNo = PRH.ProdRouteHistNo
						FROM
								STB_ProdRouteHist PRH WITH(NOLOCK)
						WHERE
								PRH.ControlNo = @ControlNo AND
								PRH.RouteCode = @AftRouteCode
						ORDER BY
								PRH.ProdDateTime DESC
	
						EXEC usp_DoAddProdRouteHistByWorkerList	@pProcessUserID = @pProcessUserID,
																				@pProcessLanguage = @pProcessLanguage,
																				@pProdRouteHistNo = @ProdRouteHistNo,
																				@pWorkerCode = @WorkerList
					 END
			
	END

	-- 현공정 작업자정보 업데이트 2019.08.21 By Jackaroe
	UPDATE STB_ProdRouteHist
	   SET WorkerCode = @WorkerCode
	      ,MachineCode = @MachineCode
		  ,ProdDateTime = GETDATE()
	 WHERE ControlNo = @ControlNo
	   AND RouteCode = @RouteCode

	-- 생산공정실적번호 
	SELECT
			TOP 1
			@ProdRouteHistNo = PRH.ProdRouteHistNo
	FROM
			STB_ProdRouteHist PRH WITH(NOLOCK)
	WHERE
			PRH.ControlNo = @ControlNo AND
			PRH.RouteCode = @RouteCode
	ORDER BY
			PRH.ProdDateTime DESC

	-- 작업자 리스트 정보 업데이트
	UPDATE STB_ProdRouteWorkerHist
	   SET WorkerCode = @WorkerCode
	 WHERE ProdRouteHistNo = @ProdRouteHistNo

	 -- MarkingLetter (마킹문자) Update
	 UPDATE STB_SetInfo
	    SET SIExtText07 = @MarkingLetter
	  WHERE ControlNo = @ControlNo


        
		-- 모델의 직경확인
	 --   DECLARE @MBISizeW BIT

		--Select @MBISizeW = VM.MBISizeW
		--From VW_ModelBasicInfo VM 
		--        LEFT OUTER JOIN STB_SetInfo SS  ON SS.MaterialCode = VM.ModelCode
		--WHERE 1=1
		--   AND ControlNo = @ControlNo		   

	 -- -- IntrinsicQty Update  (2020.01.23 파괴검사 진성불량수 추가 kilee)   --> 테스트바코드 :  VJKJ273R036710
	 -- 	--IF @IntrinsicQty is null
  --        IF @MBISizeW <= 10

		 --  BEGIN 				
					UPDATE STB_SetInfo
					     SET SIExtInt02 = @IntrinsicQty
					WHERE ControlNo = @ControlNo
		  -- END
       


	--Declare @NextRouteHistCheck INT

	--SELECT @NextRouteHistCheck = COUNT(*)
	--  FROM STB_ProdRouteHist
	-- WHERE ControlNo IN (SELECT ControlNo FROM STB_SetInfo WHERE Barcode = @Barcode)
	--   AND RouteCode = @AftRouteCode

	/*
	IF @NextRouteHistCheck = 0 BEGIN
		EXEC SmartFramework.dbo.usp_GetAddonStringResource	@pProcessLanguage,
										'^실적처리가 정상적으로 처리되지 않았습니다.^',
										@ErrorMessage OUTPUT
		SET @ErrorMessage = @ErrorMessage + ' [%s]'
		RAISERROR(@ErrorMessage,16,1,@Barcode)
		RETURN
	END
	*/
END


-- [진성검사불량수 입력 Test]
-- Select SIExtInt02, * From Stb_Setinfo where barcode = 'VJKJ273R036710'