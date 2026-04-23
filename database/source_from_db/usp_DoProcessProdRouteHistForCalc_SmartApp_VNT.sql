

-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-09-07
-- Browsable : true
-- Group : 현장용
-- Description: 불량수량을 계산하여 다음 공정으로 실적처리 합니다  [B530] 제품생산실적입력-실적완료 Button
-- Modified: 2020.01.28 진성검사불량수 추가

-- =============================================

CREATE PROCEDURE [dbo].[usp_DoProcessProdRouteHistForCalc_SmartApp_VNT]
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

	-- 지지체 구분용 변수
	Declare @WorkCenterCode VARCHAR(20),
	@WorkCenterCode1 VARCHAR(20)
	Declare @MaterialCode VARCHAR(20)

	-- 자주검사 입력완료 확인
	DECLARE @IsSelfInspectionFinish BIT

	-- MEA 에이징 타임 비교
	Declare @PrevProdDateTime DATETIME

	-- 조립 일일 작업 지시 계획일
	Declare @DayProdPlanDate DATE

	SELECT @WorkCenterCode1 = WorkCenterCode
	FROM STB_RouteInfo
	WHERE RouteCode = @RouteCode

	 
	 --Mr.Triều Kiểm tra xem đã nhập mã điện cực âm và đương hay chưa nếu chưa thì bắn lỗi 
	 IF(@WorkCenterCode1 in ('VVT_F1','VVT_F2') and @RouteCode in ('V-22','V-22_BG'))
	 begin
	     EXEC usp_CheckInputElectrodeInputForCodeProduct @Barcode,@RouteCode
	 end
	 
	--Chặn không cho lưu 실적 nếu chưa nhập NVL cho Lắp Cao Su và Curling
	 IF(@WorkCenterCode1 in ('VVT_F1','VVT_F2') and @RouteCode in ('V-23', 'V-24'))
	 begin
         EXEC usp_CheckInputRawMaterialCodeForProduct @Barcode,@RouteCode
	 end


	--- Kiểm tả xem công đoạn PQC đã nhập hay chưa nếu mà PQC chưa nhập thì bắt buộc bắn lỗi
	if(@Barcode like 'VE%' and @WorkCenterCode1 ='VVT_F3' and @RouteCode in ('VE01','VE03','VE04','VE08'))
	begin
		DECLARE @NG_Count INT;
	SELECT
		@NG_Count = COUNT(DRI.DefectSummaryNo)
	FROM
			STB_DefectRepairInfo DRI WITH(NOLOCK)
			INNER JOIN STB_SetInfo SI WITH(NOLOCK) ON SI.ControlNo = DRI.ControlNo
			LEFT OUTER JOIN STB_DefectInfo DI WITH(NOLOCK) ON DI.DefectCode = DRI.DefectCode
	WHERE
			(SI.Barcode = @Barcode) AND
			DRI.FindRouteCode = @RouteCode AND
			DI.DirectlyUnder IN ('PQC') AND 
			(DRI.RepairType IS NULL OR DRI.RepairType NOT IN ('FINISH')) AND 
			DRI.DefectCode NOT IN (SELECT DefectCode FROM dbo.fn_VVT_QCPARTCODE() WHERE flag ='QC') 
   
	IF (ISNULL(@NG_Count, 0) <= 0)
        BEGIN
             RAISERROR (N'Bên PQC chưa nhập số lượng NG. Vui lòng bảo bên PQC nhập số lượng NG.', 16, 1)
             RETURN
        END
	end
	--end


	-- Kiểm tra xem đã nhập đủ nguyên liệu theo từng công đoạn hay chưa nếu chưa không hoàn thành được kết quả sản xuất
	if(@Barcode like 'VE%' and @WorkCenterCode1 ='VVT_F3' and @RouteCode='VE06')
	begin
		exec usp_CheckInputRawMaterialCodeForProduct @Barcode,@RouteCode	
	end
	-- Làm cho Nhà máy Hà Nam

	


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
	      ,@WorkCenterCode = WorkCenterCode
	  FROM STB_RouteInfo
	 WHERE RouteCode = @RouteCode

	SELECT @SIExtInt01 = SIExtInt01
	      ,@MaterialCode = MaterialCode
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
		-- 조립 타발 공정 추가 2025.11.25
	if(@routecode IN ('V-33', 'P-01'))
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


	--- 2022.03.28 설비미등록 체크  (노승한)

		--IF ISNULL(@MachineCode,'') = ''  AND @CompanyCode = 'VNT' AND  @RouteCode <> 'E-27' AND @RouteCode <> 'E-28' AND @RouteCode <> 'E-34' AND @RouteCode <> 'E-40'
		-- 공정이 변동될 가능성이 있어 공정정보 테이블에 설비 필수여부를 추가하고 쿼리를 변경함. 2022.08.29 By Jackaroe
		IF ISNULL(@MachineCode,'') = ''  AND @CompanyCode = 'VNT' AND  @RouteCode IN (SELECT RouteCode 
		                                                                                FROM STB_RouteInfo 
																					   WHERE IsRequireMachine = CONVERT(BIT, 1))
		BEGIN
				EXEC usp_RaiseLocalizedError @pProcessLanguage, '설비를 등록하지 않았습니다. 등록이후에 진행하시기 바랍니다.'
				RETURN
		END
		--- END


		---------------------------------------------------------

	--IF ISNULL(@PONo,'') = ''
	--	BEGIN
	--			EXEC usp_RaiseLocalizedError @pProcessLanguage,'Routing에 없는 공정이거나 마지막공정입니다'
	--			RETURN
	--	END

		---------------------------------------------------------
		--- Hanguyen add 14/06/2024
		/*
	-- Mr.Triều kiểm tra xem có phải là công đoạn cuối hay không nếu không phải là tiếp tục(2026-04-04)
      DECLARE @CurrentIsOutputRoute BIT
      SELECT @CurrentIsOutputRoute = IsOutputRoute 
      FROM STB_ProductionOrderRouting 
      WHERE PONo = @PONo AND RouteCode = @RouteCode
	  */
		IF  (ISNULL(@PONo,'') = ''  AND  @CompanyCode = 'VNT')
		BEGIN
				EXEC usp_RaiseLocalizedError @pProcessLanguage,'Routing에 없는 공정이거나 마지막공정입니다'
				RETURN
		END
		

		IF  (ISNULL(@PONo,'') = ''  AND  @CompanyCode = 'VVT') --and @CurrentIsOutputRoute <> 1)
		BEGIN
				EXEC usp_RaiseLocalizedError @pProcessLanguage,N'Công đoạn này không có trong Routing hoặc là công đoạn cuối cùng.'
				RETURN
		END

		--------------------------------------------------------------

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

	SELECT @DayProdPlanDate = PlanDate
	  FROM STB_DayProdPlan DPP
	 WHERE DayPlanNo = (
		SELECT DayPlanNo
		  FROM STB_SetInfo
		 WHERE Barcode = @Barcode
	 )

	
	IF ISNULL(@IsInputRoute,0) = 1 AND DATEDIFF(Day, @DayProdPlanDate, GETDATE()) > 60 BEGIN
		EXEC SmartFramework.dbo.usp_GetAddonStringResource	@pProcessLanguage, '^현재의 작업지시는 너무 오래되었습니다. 새로운 작업지시를 등록한 후 실적을 처리해주십시오.^', @ErrorMessage OUTPUT
		SET @ErrorMessage = @ErrorMessage + ' [%s]'
		RAISERROR(@ErrorMessage,16,1,@Barcode)
		RETURN
	END
	
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

			SET @ErrorMsg = '투입공정 실적처리 에러' --@RouteName + @RouteCode + ' 공정에서 실적을 입력하지 않았습니다'
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
		-- DECLARE @test VARCHAR(50) = @AftProdQty
		--raiserror(@test,16,1)
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

            
			IF @RouteCode <> 'E-33'  AND ISNULL(@AftProdQty,0) = 0 
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
		  ,CompleteRoute='1'
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

	-- 지지체의 경우 현 공정의 생산실적 업데이트 To-Do
	-- PO 생성 시 실적수량을 기준으로 작업하도록 프로세스 변경 2022.12.14 By Jackaroe
	--IF @CompanyCode = 'VNT' 
	--     AND @WorkCenterCode = 'VNT_F2' 
	--	 AND @RouteCode LIKE 'S%' 
	--	 AND ISNULL(@MarkingLetter, '') <> '' 
	--BEGIN
	--	UPDATE STB_ProdRouteHist
	--	   SET ProdQty = CONVERT(NUMERIC(20,5), @MarkingLetter)
	--	 WHERE ProdRouteHistNo = @ProdRouteHistNo

	--	-- STB_ProdRouteSummary 도 수정해줘야함. To-Do
	--END

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
       

	-- MEA 에이징 타임 체크
	IF @RouteCode = 'EM-02' BEGIN 
		SELECT @PrevProdDateTime = ProdDateTime
		  FROM STB_ProdRouteHist
		 WHERE ControlNo = @ControlNo
		   AND RouteCode = 'EM-01'

		 IF DATEDIFF(hour, @PrevProdDateTime, DATEADD(hour, -3, GETDATE())) < 12 BEGIN
			EXEC usp_RaiseLocalizedError @pProcessLanguage,'에이징 시간이 12시간보다 작습니다. 확인 바랍니다.'
			RETURN
		 END
	END

	-- 택타임 관리를 위한 실적처리 시간 저장
	-- 공정 시작 시간을 입력할 수 있는 권한을 베트남 법인에만 부여했으므로 1차적으로는 법인 사업장만 적용함. 
	-- 이후 전 사업장으로 확대
	IF @CompanyCode = 'VVT' BEGIN
		exec usp_DoCreateTaktTimeForRoute @pProcessLanguage, @pProcessUserID, @CompanyCode, @WorkCenterCode, @Barcode, @RouteCode, @ProdQty
	END


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
-- Select SIExtInt02, * From Stb_Setinfo where barcode = 'VVOJ223R018616'


--select 240120000015
