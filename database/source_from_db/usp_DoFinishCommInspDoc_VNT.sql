-- =============================================
-- Author:		Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-09-09
-- Browsable : true
-- Group : 품질관리
-- Description:	공용 검사를 완료처리합니다
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoFinishCommInspDoc_VNT]
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

			EXEC usp_DoFinishCommInspDoc	@pProcessUserID = @ProcessUserID,
											@pProcessLanguage = @ProcessLanguage,
											@pCommInspDocNo = @CommInspDocNo,
											@pIsCheckItem = @IsCheckItem

	END
END