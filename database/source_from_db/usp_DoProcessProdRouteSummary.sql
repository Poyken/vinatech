-- =============================================
-- Author:		Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Browsable : false
-- Group : 현장용
-- Create date: 2018-08-02
-- Description:	공정별 실적 처리
-- Modified: #210621 실적 재처리 시 최조 입력 시점이 아닌 현재 시점으로 처리하도록 프로세스 변경.
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoProcessProdRouteSummary]
	@pCompanyCode VARCHAR(20),
	@pWorkCenterCode VARCHAR(20),
	@pLineCode VARCHAR(20),
	@pRouteCode VARCHAR(20),
	@pPONo VARCHAR(20),
	@pJobDate DATE,
	@pShiftCode VARCHAR(1),
	@pTimeCode VARCHAR(2),
	@pSubRouteCode VARCHAR(20) = NULL,
	@pMachineCode VARCHAR(20) = NULL,
	@pMoldNumber VARCHAR(20) = NULL,
	@pInputQty NUMERIC(20,5) = NULL,
	@pProdQty NUMERIC(20,5) = NULL,
	@pDefectQty NUMERIC(20,5) = NULL,
	@pRepairQty NUMERIC(20,5) = NULL,
	@pLossQty NUMERIC(20,5) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
			@CompanyCode VARCHAR(20) = @pCompanyCode,
			@WorkCenterCode VARCHAR(20) = @pWorkCenterCode,
			@LineCode VARCHAR(20) = @pLineCode,
			@RouteCode VARCHAR(20) = @pRouteCode,
			@PONo VARCHAR(20) = @pPONo,
			@SubRouteCode VARCHAR(20) = ISNULL(@pSubRouteCode, ''),
			@MachineCode VARCHAR(20) = ISNULL(@pMachineCode,''),
			@MoldNumber VARCHAR(20) = ISNULL(@pMoldNumber,''),
			@InputQty NUMERIC(20,5) = ISNULL(@pInputQty,0),
			@ProdQty NUMERIC(20,5) = ISNULL(@pProdQty,0),
			@DefectQty NUMERIC(20,5) = ISNULL(@pDefectQty,0),
			@RepairQty NUMERIC(20,5) = ISNULL(@pRepairQty,0),
			@LossQty NUMERIC(20,5) = ISNULL(@pLossQty,0)

	DECLARE @MaterialCode VARCHAR(50),
			@PlanJobDate VARCHAR(8),
			@ShiftCode VARCHAR(1),
			--@TimeCode VARCHAR(1),
			@TimeCode VARCHAR(2),		-- 2019-10-15 JGH 수정
			@JobDate DATE,
			@ProductSummaryID VARCHAR(20) = NULL,
			-- 08:30 교대 기준 날짜 계산
			@CurrentDate DATE = CASE WHEN CONVERT(char(8), GETDATE(), 108) < '08:30:00' THEN DATEADD(day, -1, GETDATE()) ELSE GETDATE() END
	
	SET @JobDate = @pJobDate			
	SET @ShiftCode = @pShiftCode
	SET @TimeCode = @pTimeCode

	SELECT
			@MaterialCode = POI.MaterialCode
	FROM
			STB_ProductionOrderInfo POI
	WHERE
			POI.PONo = @PONo
	
	SELECT
			@ProductSummaryID = PRS.ProductSummaryID
	FROM
			STB_ProdRouteSummary PRS
	WHERE
			PRS.CompanyCode = @CompanyCode AND
			PRS.WorkCenterCode = @WorkCenterCode AND
			PRS.LineCode = @LineCode AND
			PRS.RouteCode = @RouteCode AND
			PRS.SubRouteCode = @SubRouteCode AND
			PRS.PONo = @PONo AND
			PRS.MachineCode = @MachineCode AND
			PRS.MoldNumber = @MoldNumber AND
			PRS.MaterialCode = @MaterialCode AND
			PRS.JobDate = @JobDate AND
			PRS.ShiftCode = @ShiftCode AND
			PRS.TimeCode = @TimeCode
				  
	IF @ProductSummaryID IS NULL BEGIN
		EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_ProdRouteSummary',@ProductSummaryID OUTPUT
		
		INSERT INTO STB_ProdRouteSummary
		(
			ProductSummaryID,
			CompanyCode,
			WorkCenterCode,
			JobDate,
			ShiftCode,
			TimeCode,
			PONo,
			MaterialCode,
			LineCode,
			RouteCode,
			SubRouteCode,
			MachineCode,
			MoldNumber,
			InputQty,
			OutputQty,
			DefectQty,
			RepairQty,
			LossQty,
			BackFlushQty
		)
		VALUES
		(
			@ProductSummaryID,
			@CompanyCode,
			@WorkCenterCode,
			@JobDate,
			@ShiftCode,
			@TimeCode,
			@PONo,
			@MaterialCode,
			@LineCode,
			@RouteCode,
			@SubRouteCode,
			@MachineCode,
			@MoldNumber,
			@InputQty,
			@ProdQty,
			@DefectQty,
			@RepairQty,
			@LossQty,
			0
		)
	END ELSE BEGIN
		-- #210621
		-- 재처리가 공정투입일자와 같은 날이면 프로세스 변경 없음.
		IF @JobDate = @CurrentDate BEGIN
			-- 
			UPDATE STB_ProdRouteSummary
			SET
					InputQty = InputQty + @InputQty,
					OutputQty = OutputQty + @ProdQty,
					DefectQty = DefectQty + @DefectQty,
					RepairQty = RepairQty + @RepairQty,
					LossQty = LossQty + @LossQty
			WHERE
					ProductSummaryID = @ProductSummaryID
		END ELSE BEGIN
			-- 재처리가 공정투입일자와 다른 날이면, 
			-- ProductSummaryID 기준으로 실적을 차감한 다음 
			UPDATE STB_ProdRouteSummary
			SET
					InputQty = InputQty - @InputQty,
					OutputQty = OutputQty - @ProdQty,
					DefectQty = DefectQty - @DefectQty,
					RepairQty = RepairQty - @RepairQty,
					LossQty = LossQty + @LossQty
			WHERE
					ProductSummaryID = @ProductSummaryID

			-- 처리일자로 실적처리가 된 상황이면, 
			-- ProductSummaryID를 새로 구해서 업데이트 한다.
			IF EXISTS (SELECT 1
						 FROM STB_ProdRouteSummary PRS
						WHERE PRS.CompanyCode = @CompanyCode AND
				  		 	  PRS.WorkCenterCode = @WorkCenterCode AND
				  		 	  PRS.LineCode = @LineCode AND
				  		 	  PRS.RouteCode = @RouteCode AND
				  		 	  PRS.SubRouteCode = @SubRouteCode AND
				  		 	  PRS.PONo = @PONo AND
				  		 	  PRS.MachineCode = @MachineCode AND
				  		 	  PRS.MoldNumber = @MoldNumber AND
				  		 	  PRS.MaterialCode = @MaterialCode AND
				  		 	  PRS.JobDate = @CurrentDate AND
				  		 	  PRS.ShiftCode = @ShiftCode AND
				  		 	  PRS.TimeCode = @TimeCode) BEGIN

				-- 현시점 기준의 SummaryID 
				SELECT @ProductSummaryID = PRS.ProductSummaryID
				  FROM STB_ProdRouteSummary PRS
				 WHERE  PRS.CompanyCode = @CompanyCode AND
						PRS.WorkCenterCode = @WorkCenterCode AND
						PRS.LineCode = @LineCode AND
						PRS.RouteCode = @RouteCode AND
						PRS.SubRouteCode = @SubRouteCode AND
						PRS.PONo = @PONo AND
						PRS.MachineCode = @MachineCode AND
						PRS.MoldNumber = @MoldNumber AND
						PRS.MaterialCode = @MaterialCode AND
						PRS.JobDate = @CurrentDate AND
						PRS.ShiftCode = @ShiftCode AND
						PRS.TimeCode = @TimeCode

				-- 실적 업데이트
				UPDATE STB_ProdRouteSummary
				   SET InputQty = InputQty + @InputQty,
					   OutputQty = OutputQty + @ProdQty,
					   DefectQty = DefectQty + @DefectQty,
					   RepairQty = RepairQty + @RepairQty,
					   LossQty = LossQty + @LossQty
				 WHERE ProductSummaryID = @ProductSummaryID
			END ELSE BEGIN
				-- 처리일자의 실적 집계가 쌓이기 전이면 ProductSummaryID를 채번하여 새로 입력한다.
				EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_ProdRouteSummary',@ProductSummaryID OUTPUT
		
				INSERT INTO STB_ProdRouteSummary
				(
					ProductSummaryID,
					CompanyCode,
					WorkCenterCode,
					JobDate,
					ShiftCode,
					TimeCode,
					PONo,
					MaterialCode,
					LineCode,
					RouteCode,
					SubRouteCode,
					MachineCode,
					MoldNumber,
					InputQty,
					OutputQty,
					DefectQty,
					RepairQty,
					LossQty,
					BackFlushQty
				)
				VALUES
				(
					@ProductSummaryID,
					@CompanyCode,
					@WorkCenterCode,
					@CurrentDate,
					@ShiftCode,
					@TimeCode,
					@PONo,
					@MaterialCode,
					@LineCode,
					@RouteCode,
					@SubRouteCode,
					@MachineCode,
					@MoldNumber,
					@InputQty,
					@ProdQty,
					@DefectQty,
					@RepairQty,
					@LossQty,
					0
				)
			END
		END
	END
END
