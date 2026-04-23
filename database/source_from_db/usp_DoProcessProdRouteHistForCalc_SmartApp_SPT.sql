

-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2024-03-15
-- Browsable : true
-- Group : 생산관리
-- Description: 

-- =============================================

CREATE PROCEDURE [dbo].[usp_DoProcessProdRouteHistForCalc_SmartApp_SPT]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pBarcode VARCHAR(50),
	@pRouteCode VARCHAR(20),
	@pWorkerCode VARCHAR(20) = NULL,
	@pWorkerList VARCHAR(200) = NULL,
	@pMachineCode VARCHAR(20) = NULL,
	@pMachineID VARCHAR(20) = NULL,
	@pProdQty NUMERIC(20,5) = NULL
AS

BEGIN
	SET NOCOUNT ON;

	DECLARE @Barcode VARCHAR(50) = @pBarcode
	DECLARE @RouteCode VARCHAR(20) = @pRouteCode
	DECLARE @WorkerCode VARCHAR(20) = ISNULL(@pWorkerCode,'')
	DECLARE @WorkerList VARCHAR(200) = ISNULL(@pWorkerList,'')
	DECLARE @MachineID VARCHAR(20) = ISNULL(@pMachineID,'')
	DECLARE @MachineCode VARCHAR(20) = ISNULL(@pMachineCode,'')        

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
	DECLARE @ProdRouteHistNo VARCHAR(20)
	DECLARE @CompanyCode VARCHAR(20)

	-- 지지체 구분용 변수
	Declare @WorkCenterCode VARCHAR(20)
	Declare @MaterialCode VARCHAR(20)

	-- 자주검사 입력완료 확인
	DECLARE @IsSelfInspectionFinish BIT

	Declare @BefRouteCode VARCHAR(20)
	Declare @IsBefRouteFinish INT

	-- 조립 일일 작업 지시 계획일
	Declare @DayProdPlanDate DATE


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


	-- 현공정 정보와 다음공정 정보 가져오기
	SELECT
			TOP 1
			@RouteCode = POR.RouteCode,
			@IsOutputRoute = POR.IsOutputRoute,
			@PONo = POR.PONo,
			@ControlNo = SI.ControlNo,
			@LineCode = SI.InputLineCode,
			@LotQty = SI.ProdQty,
			@IsInputRoute = POR.IsInputRoute,
			@PlanLineCode = DPP.LineCode,
			@RouteIndex = POR.RouteIndex
	FROM
			STB_SetInfo SI WITH(NOLOCK)
			INNER JOIN STB_ProductionOrderRouting  POR WITH(NOLOCK)				ON POR.PONo = SI.PONo              AND				POR.RouteCode = @RouteCode
			INNER JOIN STB_DayProdPlan                 DPP WITH(NOLOCK)			    ON DPP.DayPlanNo = SI.DayPlanNo
	WHERE
			SI.Barcode = @Barcode
	ORDER BY
			POR.RouteIndex

	-- 지지체는 공정검사에서 불합격 판정이 나질 않음.
	--IF ISNULL(@IsHolding,0) = 1 BEGIN
	--		EXEC SmartFramework.dbo.usp_GetAddonStringResource	@pProcessLanguage,
	--																				'^공정검사 불합격 제품입니다^',
	--																				@ErrorMessage OUTPUT
	--		SET @ErrorMessage = @ErrorMessage + ' [%s]'
	--		RAISERROR(@ErrorMessage,16,1,@Barcode)
	--		RETURN
	--END

	IF @IsOutputRoute = CONVERT(BIT, 1) BEGIN
		EXEC usp_RaiseLocalizedError @pProcessLanguage, '처리할 Lot의 최종실적입니다. 제품 박스실적입력 화면에서 처리하세요.'
		RETURN
	END

	SET @ProdQty = @pProdQty

	SET @ProdQty = ISNULL(@ProdQty, 0)

	SELECT @DayProdPlanDate = PlanDate
	  FROM STB_DayProdPlan DPP
	 WHERE DayPlanNo = (
		SELECT DayPlanNo
		  FROM STB_SetInfo
		 WHERE Barcode = @Barcode
	 )

	IF ISNULL(@IsInputRoute,0) = 1 AND DATEDIFF(Day, @DayProdPlanDate, GETDATE()) > 30 BEGIN
		EXEC SmartFramework.dbo.usp_GetAddonStringResource	@pProcessLanguage, '^현재의 작업지시는 너무 오래되었습니다. 새로운 작업지시를 등록한 후 실적을 처리해주십시오.^', @ErrorMessage OUTPUT
		SET @ErrorMessage = @ErrorMessage + ' [%s]'
		RAISERROR(@ErrorMessage,16,1,@Barcode)
		RETURN
	END

	IF @IsInputRoute = CONVERT(BIT, 1) BEGIN 
		SET @LineCode = @PlanLineCode

		EXEC usp_DoProcessProdRouteHist_VNT	@pProcessUserID = @pProcessUserID,
											@pProcessLanguage = @pProcessLanguage,
											@pBarcode = @pBarcode,
											@pLineCode = @LineCode,
											@pRouteCode = @RouteCode,
											@pWorkerCode = @WorkerCode,
											@pProdQty = @ProdQty,
											@pMachineCode = @MachineCode,
											@pMachineID = @MachineID
	END ELSE BEGIN
		SELECT @BefRouteCode = RouteCode
		  FROM STB_ProductionOrderRouting
		 WHERE RouteIndex = @RouteIndex - 1
		   AND PONo = @PONo

		SELECT @IsBefRouteFinish = COUNT(*)
		  FROM STB_ProdRouteHist
		 WHERE ControlNo = @ControlNo
		   AND RouteCode = @BefRouteCode

		IF @IsBefRouteFinish = 0 BEGIN
			EXEC usp_RaiseLocalizedError @pProcessLanguage, '이전 공정 실적이 처리되지 않았습니다.'
			RETURN
		END
		
		EXEC usp_DoProcessProdRouteHist_VNT	@pProcessUserID = @pProcessUserID,
											@pProcessLanguage = @pProcessLanguage,
											@pBarcode = @pBarcode,
											@pLineCode = @LineCode,
											@pRouteCode = @RouteCode,
											@pWorkerCode = @WorkerCode,
											@pProdQty = @ProdQty,
											@pMachineCode = @MachineCode,
											@pMachineID = @MachineID
	END

	       

	IF @WorkerList <> ''  BEGIN		-- 작업자가 여러명일경우
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