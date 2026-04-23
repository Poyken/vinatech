
-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-17
-- Browsable : true
-- Group : 생산관리
-- Description: 공정별 실적을 처리합니다 비나텍용
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoProcessProdRouteHist_VNT]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pBarcode VARCHAR(50) = NULL,
	@pLineCode VARCHAR(20) = NULL,
	@pRouteCode VARCHAR(20) = NULL,
	@pWorkerCode VARCHAR(20) = NULL,
	@pProdQty NUMERIC(20,5) = NULL,
	@pProcessDateTime DATETIME = NULL,
	@pMachineID VARCHAR(20) = NULL,
	@pMachineCode VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
	DECLARE @LineCode VARCHAR(20) = @pLineCode
	DECLARE @RouteCode VARCHAR(20) = @pRouteCode
	DECLARE @WorkerCode VARCHAR(20) = ISNULL(@pWorkerCode,'')
	DECLARE @Barcode VARCHAR(50) = @pBarcode
	DECLARE @ProcessDateTime DATETIME = ISNULL(@pProcessDateTime,GETDATE())
	DECLARE @MachineID VARCHAR(20) = ISNULL(@pMachineID,'')
	DECLARE @ProdQty NUMERIC(20,5) = @pProdQty
	DECLARE @MachineCode VARCHAR(20) = ISNULL(@pMachineCode,'')
	DECLARE @BasicPackingQty NUMERIC(20,5)
	DECLARE @MaterialCode VARCHAR(50)

	DECLARE @CompanyCode VARCHAR(20)
	DECLARE @WorkCenterCode VARCHAR(20)
	DECLARE @PONo VARCHAR(20)
	DECLARE @ControlNo VARCHAR(20)
	DECLARE @LotID VARCHAR(50)
	DECLARE @LotNo VARCHAR(50)
	DECLARE @ErrorMessage NVARCHAR(500)
	DECLARE @Data VARCHAR(MAX)
	DECLARE @CurrentQty NUMERIC(20,5)
	DECLARE @TotalQty NUMERIC(20,5)
	DECLARE @IsHolding BIT
	DECLARE @InputLineCode VARCHAR(20)
	
	IF ISNULL(@Barcode,'') <> '' BEGIN
			SELECT
					@PONo = SI.PONo,
					@ControlNo = SI.ControlNo,
					@LotID = SI.Barcode,
					@LotNo = ISNULL(SI.SIExtText01,''),
					@BasicPackingQty = MM.BasicPackingQty,
					@MaterialCode = SI.MaterialCode,
					@TotalQty = SI.ProdQty,
					@IsHolding = SI.SIExtInt01,
					@InputLineCode = SI.InputLineCode,
					@CompanyCode = POI.CompanyCode,
					@WorkCenterCode = POI.WorkCenterCode
			FROM
					STB_SetInfo SI WITH(NOLOCK)
					LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)
						ON MM.MaterialCode = SI.MaterialCode
					INNER JOIN STB_ProductionOrderInfo POI WITH(NOLOCK)
						ON POI.PONo = SI.PONo
			WHERE
					SI.Barcode = @Barcode

			IF ISNULL(@InputLineCode,'') <> '' BEGIN
					SET @LineCode = @InputLineCode
			END

			IF ISNULL(@LineCode,'') = '' BEGIN
					EXEC SmartFramework.dbo.usp_GetAddonStringResource	@ProcessLanguage,
													'^투입되지 않은 Lot입니다^',
													@ErrorMessage OUTPUT
					SET @ErrorMessage = @ErrorMessage + ' [%s]'
					RAISERROR(@ErrorMessage,16,1,@Barcode)
					RETURN
			END

			SELECT
					@IsHolding = SI.SIExtInt01
			FROM
					STB_SetInfo SI WITH(NOLOCK)
			WHERE
					SI.Barcode = @Barcode

			IF ISNULL(@IsHolding,0) = 1 BEGIN
					EXEC SmartFramework.dbo.usp_GetAddonStringResource	@ProcessLanguage,
													'^공정검사 불합격 제품입니다^',
													@ErrorMessage OUTPUT
					SET @ErrorMessage = @ErrorMessage + ' [%s]'
					RAISERROR(@ErrorMessage,16,1,@Barcode)
					RETURN
			END
			
			SET @ProcessDateTime = GETDATE()

			IF @ProdQty IS NOT NULL BEGIN		-- 제품
					IF EXISTS (
									SELECT		1
									FROM
											STB_ProductionOrderRouting POR
									WHERE
											POR.PONo = @PONo AND
											POR.RouteCode = @RouteCode AND
											POR.IsOutputRoute = 1
							) BEGIN
							EXEC SmartFramework.dbo.usp_GetAddonStringResource	@ProcessLanguage,
																				'^최종공정은 박스실적입력에서 스캔하세요^',
																				@ErrorMessage OUTPUT
							SET @ErrorMessage = @ErrorMessage + ' [%s]'
							RAISERROR(@ErrorMessage,16,1,@RouteCode)
							RETURN

					END
					DECLARE @Header VARCHAR(20)
					DECLARE @Year INT = DATEPART(YEAR,@ProcessDateTime)
					DECLARE @Month INT = DATEPART(MONTH,@ProcessDateTime)
					DECLARE @YearCode VARCHAR(1)
					DECLARE @MonthCode VARCHAR(1) = CHAR(@Month + 73)	-- 1월이 J부터 시작
					DECLARE @DayCode VARCHAR(2) = RIGHT('00' + CONVERT(VARCHAR,DATEPART(DAY,@ProcessDateTime)),2)
					DECLARE @SerialNo INT

					SET @Header = @YearCode + @MonthCode + @DayCode

					SELECT
							@CurrentQty = SUM(PRH.ProdQty)
					FROM
							STB_ProdRouteHist PRH
					WHERE
							PRH.ControlNo = @ControlNo AND
							PRH.RouteCode = @RouteCode

					IF ISNULL(@CurrentQty,0) + @ProdQty > @TotalQty BEGIN
							EXEC SmartFramework.dbo.usp_GetAddonStringResource	@ProcessLanguage,
															'^Lot 총수량을 초과할수 없습니다^',
															@ErrorMessage OUTPUT
							SET @ErrorMessage = @ErrorMessage + ' [%s] ' + CONVERT(VARCHAR,@CurrentQty) + '/' + CONVERT(VARCHAR,@TotalQty)
							RAISERROR(@ErrorMessage,16,1,@Barcode)
							RETURN
					END

					--EXEC usp_GetNewSerialNoForBarcode	@pProcessUserID = @pProcessUserID,
					--									@pMaterialCode = @MaterialCode,
					--									@pHeader = @Header,
					--									@pSerialNo = @SerialNo OUTPUT

					--SET @LotID = @MaterialCode + @Header + RIGHT('00000' + CONVERT(VARCHAR,@SerialNo),5)
					--SET @LotNo = @Barcode
					SET @LotID = ''
					SET @LotNo = ''
			END ELSE BEGIN
					IF EXISTS (
								SELECT	1
								FROM
										STB_ProdRouteHist PRH
								WHERE
										PRH.ControlNo = @ControlNo AND
										PRH.RouteCode = @RouteCode
							) BEGIN
							EXEC SmartFramework.dbo.usp_GetAddonStringResource	@ProcessLanguage,
															'^이미 처라힌 바코드입니다^',
															@ErrorMessage OUTPUT
							SET @ErrorMessage = @ErrorMessage + ' [%s]'
							RAISERROR(@ErrorMessage,16,1,@Barcode)
							RETURN
					END
			END
					
			SET @Data = LEFT('PRODROUTE' + REPLICATE(' ',20),20) +
						LEFT(@LineCode + REPLICATE(' ',20),20) +
						LEFT(@RouteCode + REPLICATE(' ',20),20) +
						dbo.fnConvertDateTimeToVarChar('yyyyMMddHHmissfff',@ProcessDateTime) +
						LEFT(@Barcode + REPLICATE(' ',50),50) +
						LEFT(@WorkerCode + REPLICATE(' ',20),20) +
						LEFT(@LotID + REPLICATE(' ',50),50) +
						LEFT(@LotNo + REPLICATE(' ',50),50) +
						LEFT(@MachineCode + REPLICATE(' ',20),20)

			IF @ProdQty IS NOT NULL BEGIN
					SET @Data = @Data + LEFT(CONVERT(VARCHAR(20),@ProdQty) + REPLICATE(' ',10),10)
			END
			
			EXEC usp_DoProcessTerminalData	@pProcessUserID = @ProcessUserID,
											@pProcessLanguage = @ProcessLanguage,
											@pIPAddress = @MachineID,
											@pPortNo = 0,
											@pData = @Data
	END

	DECLARE @JobDateShift VARCHAR(20) = dbo.fnGetJobDateShiftTime(@ProcessDateTime,@CompanyCode,@WorkCenterCode,@LineCode,@RouteCode,NULL)
	DECLARE @JobDate DATE = SUBSTRING(@JobDateShift,1,8)
	DECLARE @ShiftCode VARCHAR(1) = SUBSTRING(@JobDateShift,9,1)

	/*
	-- 실적등록 정상여부 체크
	DECLARE @ProdQtyChk NUMERIC(20,5)

	SELECT @ProdQtyChk = ProdQty
	  FROM STB_ProdRouteHist
	 WHERE ControlNo = (SELECT ControlNo FROM STB_SetInfo WHERE Barcode = @Barcode)
	   AND RouteCode = @RouteCode

	select @ProdQtyChk

	IF @ProdQtyChk = 0 OR @ProdQtyChk IS NULL BEGIN
		EXEC SmartFramework.dbo.usp_GetAddonStringResource	@ProcessLanguage,
										'^실적처리가 정상적으로 처리되지 않았습니다.^',
										@ErrorMessage OUTPUT
		SET @ErrorMessage = @ErrorMessage + ' [%s]'
		RAISERROR(@ErrorMessage,16,1,@Barcode)
		RETURN
	END
	*/
	
	;WITH Prod AS
	(
		SELECT
				PRS.PONo,
				PRS.LineCode,
				PRS.RouteCode,
				PRS.JobDate,
				PRS.ShiftCode,
				SUM(PRS.InputQty) AS InputQty,
				SUM(PRS.OutputQty) AS OutputQty,
				SUM(PRS.DefectQty) AS DefectQty,
				SUM(PRS.LossQty) AS LossQty
		FROM
				STB_ProdRouteSummary PRS WITH(NOLOCK)
		WHERE
				PRS.PONo = @PONo AND
				PRS.LineCode = @LineCode AND
				PRS.RouteCode = @RouteCode AND
				PRS.JobDate = @JobDate AND
				PRS.ShiftCode = @ShiftCode
		GROUP BY
				PRS.PONo,
				PRS.LineCode,
				PRS.RouteCode,
				PRS.JobDate,
				PRS.ShiftCode
	)
	SELECT
			SI.ControlNo,
			SI.DayPlanNo,
			SI.PONo,
			SI.MaterialCode,
			MM.MaterialName,
			DPP.PlanDate,
			DPP.PlanQty,
			Prod.InputQty,
			Prod.OutputQty,
			Prod.DefectQty,
			Prod.LossQty
	FROM
			STB_SetInfo SI WITH(NOLOCK)
			LEFT OUTER JOIN STB_DayProdPlan DPP WITH(NOLOCK)
				ON DPP.DayPlanNo = SI.DayPlanNo
			LEFT OUTER JOIN Prod
				ON Prod.PONo = SI.PONo
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)
				ON MM.MaterialCode = SI.MaterialCode
	WHERE
			SI.Barcode = @Barcode
END

