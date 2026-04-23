-- =============================================m
-- Author:	Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Browsable : true
-- Group : 생산관리
-- Create date: 2019-10-14
-- Description:	PO 기종변경처리
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoChangeMaterialForSetInfo]  -- exec usp_DoChangeMaterialForSetInfo '', '', '20250707000301', '2025100300028'
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pControlNo VARCHAR(20),
	@pTargetDayPlanNo VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ControlNo VARCHAR(20) = @pControlNo,
			@TargetDayPlanNo VARCHAR(20) = @pTargetDayPlanNo

	DECLARE @CompanyCode VARCHAR(20),
			@WorkCenterCode VARCHAR(20),
			@MaterialCode VARCHAR(50),
			@Volt VARCHAR(20),
			@Capacity VARCHAR(20),
			@ProdFinishQty NUMERIC(20,5),
			@TargetPONo VARCHAR(20),
			@TargetMaterialCode VARCHAR(50),
			@BefMaterialCode VARCHAR(50),
			@BefDayPlanNo VARCHAR(20),
			@BefPONo VARCHAR(20),
			@OldBarcode VARCHAR(20),
			@PlanDate DATE,
			-- #2022.03.21 
			@aftCompanyCode VARCHAR(20),
			@aftWorkCenterCode VARCHAR(20)

	DECLARE @CheckModule VARCHAR(10)


	--왜 @CompanyCode를 세팅해주지 않았습니까.. !!! 2020.04.16
	SELECT @aftCompanyCode = CompanyCode -- @CompanyCode -- #2022.03.21 
	      ,@aftWorkCenterCode = WorkCenterCode
	  FROM STB_UserInfo
	 WHERE UserID = @pProcessUserID

	IF @TargetDayPlanNo = ''
	BEGIN
		RETURN
	END

	SELECT
			@ProdFinishQty = SUM(PRH.ProdQty),
			@CompanyCode = MAX(PRH.CompanyCode), -- #2022.03.21 
			@WorkCenterCode = MAX(PRH.WorkCenterCode)

	FROM
			STB_ProdRouteHist PRH
			INNER JOIN STB_ProductionOrderRouting POR
				ON POR.PONo = PRH.PONo AND
				POR.RouteCode = PRH.RouteCode AND
				POR.IsOutputRoute = 1
	WHERE
			PRH.ControlNo = @ControlNo

	IF ISNULL(@ProdFinishQty,0) > 0
	BEGIN
		EXEC usp_RaiseLocalizedError	@pProcessLanguage = @pProcessLanguage,
										@pMessage = '박스포장한 이력이 있는 LOT는 변경이 불가합니다'
		RETURN
	END

	SELECT
			@BefDayPlanNo = SI.DayPlanNo,
			@BefMaterialCode = SI.MaterialCode,
			@BefPONo = SI.PONo,
			@OldBarcode = SI.Barcode
	FROM
			STB_SetInfo SI
	WHERE
			SI.ControlNo = @ControlNo

	-- 변경 계획정보
	SELECT
			@TargetMaterialCode = DPP.MaterialCode,
			@TargetPONo = DPP.PONo,
			@Volt = MBI.MBIExtText01,
			@Capacity = MBI.MBIExtText02,
			@PlanDate = DPP.PlanDate
	FROM
			STB_DayProdPlan DPP
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)
				ON MM.MaterialCode = DPP.MaterialCode
			LEFT OUTER JOIN STB_ModelBasicInfo MBI WITH(NOLOCK)
				ON MBI.ModelCode = MM.MaterialCode
	WHERE
			DPP.DayPlanNo = @TargetDayPlanNo

	DECLARE @Summary TABLE
	(
		IDX INT IDENTITY(1,1),
		LineCode VARCHAR(20),
		RouteCode VARCHAR(20),
		JobDate DATE,
		ShiftCode VARCHAR(1),
		TimeCode VARCHAR(2),
		ProdQty NUMERIC(20,5),
		DefectQty NUMERIC(20,5),
		RepairQty NUMERIC(20,5),
		LossQty NUMERIC(20,5)
	)
	
	;WITH ProdSummary AS
	(
		-- 실적
		SELECT
				PRH.LineCode,
				PRH.RouteCode,
				PRH.JobDate,
				PRH.ShiftCode,
				PRH.TimeCode,
				SUM(PRH.ProdQty) AS ProdQty,
				0 AS DefectQty,
				0 AS RepairQty,
				0 AS LossQty
		FROM
				STB_ProdRouteHist PRH
		WHERE
				PRH.ControlNo = @ControlNo
		GROUP BY
				PRH.LineCode,
				PRH.RouteCode,
				PRH.JobDate,
				PRH.ShiftCode,
				PRH.TimeCode
		UNION ALL
		-- 불량,수리수량
		SELECT
				DRI.FindLineCode,
				DRI.FindRouteCode,
				DRI.FindJobdate,
				DRI.FindShiftCode,
				DRI.FindTimeCode,
				0,
				SUM(DRI.DefectQty),
				SUM(DRI.RepairQty),
				SUM(DRI.LossQty)
		FROM
				STB_DefectRepairInfo DRI WITH(NOLOCK)
		WHERE
				DRI.ControlNo = @ControlNo
		GROUP BY
				DRI.FindLineCode,
				DRI.FindRouteCode,
				DRI.FindJobdate,
				DRI.FindShiftCode,
				DRI.FindTimeCode
	)
		-- -- Summary에서 기존 정보로 차감하고 변경될 품목으로 Summary 재계산을 위해 실적 및 불량 이력 집계 구하기
		INSERT INTO @Summary
		SELECT
				PS.LineCode,
				PS.RouteCode,
				PS.JobDate,
				PS.ShiftCode,
				PS.TimeCode,
				SUM(PS.ProdQty),
				SUM(PS.DefectQty),
				SUM(PS.RepairQty),
				SUM(PS.LossQty)
		FROM
				ProdSummary PS
		GROUP BY
				PS.LineCode,
				PS.RouteCode,
				PS.JobDate,
				PS.ShiftCode,
				PS.TimeCode
				
	--실적 이력 Table 생산계획번호, 일일생산계획번호 품목코드 변경
	UPDATE STB_ProdRouteHist
	SET
			PONo = @TargetPONo,
			DayPlanNo = @TargetDayPlanNo,
			MaterialCode = @TargetMaterialCode
	WHERE
			ControlNo = @ControlNo

	--불량 Table 생산계획번호, 일일생산계획번호 품목코드 변경
	UPDATE	STB_DefectRepairInfo
	SET
			MaterialCode = @TargetMaterialCode,
			DayPlanNo = @TargetDayPlanNo,
			PONo = @TargetPONo
	WHERE
			ControlNo = @ControlNo

	DECLARE @RowNo INT = 1,
			@Count INT = (SELECT COUNT(*) FROM @Summary),
			@LineCode VARCHAR(20),
			@RouteCode VARCHAR(20),
			@JobDate DATE,
			@ShiftCode VARCHAR(1),
			@TimeCode VARCHAR(2),
			@ProdQty NUMERIC(20,5),
			@DefectQty NUMERIC(20,5),
			@RepairQty NUMERIC(20,5),
			@LossQty NUMERIC(20,5)
	-- Summary 계산
	WHILE @Count >= @RowNo
	BEGIN
		SELECT
				@LineCode = SM.LineCode,
				@RouteCode = SM.RouteCode,
				@JobDate = SM.JobDate,
				@ShiftCode = SM.ShiftCode,
				@TimeCode = SM.TimeCode,
				@ProdQty = ISNULL(SM.ProdQty,0),
				@DefectQty = ISNULL(SM.DefectQty,0),
				@RepairQty = ISNULL(SM.RepairQty,0),
				@LossQty = ISNULL(SM.LossQty,0)
		FROM
				@Summary SM
		WHERE
				SM.IDX = @RowNo

		-- 변경 PO번호로 Summary 증가
		EXEC usp_DoProcessProdRouteSummary	@pCompanyCode = @CompanyCode,
											@pWorkCenterCode = @WorkCenterCode,
											@pLineCode = @LineCode,
											@pRouteCode = @RouteCode,
											@pPONo = @TargetPONo,
											@pJobDate = @JobDate,
											@pShiftCode = @ShiftCode,
											@pTimeCode = @TimeCode,
											@pProdQty = @ProdQty,
											@pDefectQty = @DefectQty,
											@pRepairQty = @RepairQty,
											@pLossQty = @LossQty

		SET @ProdQty = @ProdQty * -1
		SET @DefectQty = @DefectQty * -1
		SET @RepairQty = @RepairQty * -1
		SET @LossQty = @LossQty * -1
		-- 이전 PO는 Summary 차감
		EXEC usp_DoProcessProdRouteSummary	@pCompanyCode = @CompanyCode,
											@pWorkCenterCode = @WorkCenterCode,
											@pLineCode = @LineCode,
											@pRouteCode = @RouteCode,
											@pPONo = @BefPONo,
											@pJobDate = @JobDate,
											@pShiftCode = @ShiftCode,
											@pTimeCode = @TimeCode,
											@pProdQty = @ProdQty,
											@pDefectQty = @DefectQty,
											@pRepairQty = @RepairQty,
											@pLossQty = @LossQty

		SET @RowNo = @RowNo + 1
	END

	DECLARE @Barcode VARCHAR(50)
	DECLARE @FirstString CHAR(2) = CASE WHEN @aftCompanyCode = 'VNT' -- #2022.03.21
										
										THEN 'VJ' ELSE 'VV' END
	DECLARE @Header VARCHAR(20)
	DECLARE @Year INT = DATEPART(YEAR,@PlanDate)
	DECLARE @Month INT = DATEPART(MONTH,@PlanDate)
	DECLARE @YearCode VARCHAR(1)
	DECLARE @MonthCode VARCHAR(1) = CHAR(@Month + 73)	-- 1월이 J부터 시작
	DECLARE @DayCode VARCHAR(2) = RIGHT('00' + CONVERT(VARCHAR,DATEPART(DAY,@PlanDate)),2)             --- SELECT  RIGHT('00' + CONVERT(VARCHAR,DATEPART(DAY,GETDATE()+1)),2) 
	--DECLARE @SerialNo INT
	DECLARE @SerialNo VARCHAR(20)

	SELECT
			@YearCode = YI.YearCode
	FROM
			STB_YearInfo YI WITH(NOLOCK)
	WHERE
			YI.Year = @Year

	---- Mr.Manh UPDATE 2025-10-04 following Ms.Phuong's request: Change Material for Module type
	SELECT @CheckModule = MaterialTypeCode FROM STB_ModelBasicInfo where ModelCode = @TargetMaterialCode --(Select MaterialCode From STB_SetInfo where ControlNo = @ControlNo)
	IF @CheckModule = 'MDL'
		BEGIN
			SET @Header = 'M' + @FirstString + @YearCode + @MonthCode + @DayCode + @Volt + @Capacity
		END
	ELSE
		BEGIN
			SET @Header = @FirstString + @YearCode + @MonthCode + @DayCode + @Volt + @Capacity
		END
	---------------END UPDATE--

	-- 변경 모델로 채번
	--SET @Header = @FirstString + @YearCode + @MonthCode + @DayCode + @Volt + @Capacity
	--raiserror(@Header,16,1)
	--return
	PRINT '@Header : ' + ISNULL(@Header, '*')

	--EXEC usp_GetNewSerialNoForBarcode	@pProcessUserID = @pProcessUserID,
	--									@pMaterialCode = '',
	--									@pHeader = @Header,
	--									@pSerialNo = @SerialNo OUTPUT
	
	EXEC usp_GetNewSerialNoForBarcodeUsingString @pProcessUserID = @pProcessUserID,
												@pMaterialCode = '',
												@pHeader = @Header,
												@pSerialNo = @SerialNo OUTPUT

	SET @Barcode = @Header + RIGHT('00' + CONVERT(VARCHAR,ISNULL(@SerialNo,0)), 2)

	---- Mr.Manh UPDATE 2025-08-25 following Ms.Phuong's request: Change Material for Module type
	--SELECT @CheckModule = MaterialTypeCode FROM STB_ModelBasicInfo where ModelCode = (Select MaterialCode From STB_SetInfo where ControlNo = @ControlNo)
	--IF @CheckModule = 'MDL'
	--	BEGIN
	--		SET @Barcode = 'M' + @Header + RIGHT('00' + CONVERT(VARCHAR,ISNULL(@SerialNo,0)), 2)
	--	END
	--ELSE
	--	BEGIN
	--		SET @Barcode = @Header + RIGHT('00' + CONVERT(VARCHAR,ISNULL(@SerialNo,0)), 2)
	--	END
	---------------END UPDATE--

	PRINT '@Barcode : ' + @Barcode

	-- Lot정보에 바코드,생산계획번호,일일생산계획번호, 품목코드 변경
	UPDATE	STB_SetInfo
	SET
			DayPlanNo = @TargetDayPlanNo,
			PONo = @TargetPONo,
			MaterialCode = @TargetMaterialCode,
			Barcode = @Barcode
	WHERE
			ControlNo = @ControlNo

	-- 원자재 투입 정보 변경
	UPDATE STB_RawMaterialInputHist
	   SET Barcode = @Barcode
	 WHERE Barcode = @OldBarcode

	-- 변경이력 저장
	INSERT INTO STB_LotChangeMaterialHistory
	(
		ControlNo,
		BefMaterialCode,
		BefPONo,
		BefDayPlanNo,
		AftMaterialCode,
		AftPONo,
		AftDayPlanNo,
		JobDate,
		CreateDateTime,
		CreateUserID,
		OldBarcode,
		NewBarcode
	)
	VALUES
	(
		@ControlNo,
		@BefMaterialCode,
		@BefPONo,
		@BefDayPlanNo,
		@TargetMaterialCode,
		@TargetPONo,
		@TargetDayPlanNo,
		GETDATE(),
		GETDATE(),
		@pProcessUserID,
		@OldBarcode,
		@Barcode
	)

END