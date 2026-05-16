
-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-02
-- Browsable : true
-- Group : 생산관리
-- Description: 공정별 실적을 처리합니다
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoProcessProdRouteHist]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pPONo VARCHAR(20),
	@pLineCode VARCHAR(20),
	@pRouteCode VARCHAR(20),
	@pProcessDateTime DATETIME,
	@pDayPlanNo VARCHAR(20) = NULL,
	@pControlNo VARCHAR(20) = NULL,
	@pWorkerCode VARCHAR(20) = NULL,
	@pMachineCode VARCHAR(20) = NULL,
	@pProdQty NUMERIC(20,5) = NULL,
	@pLotID VARCHAR(50) = NULL,
	@pLotNo VARCHAR(50) = NULL,
	@pStockAttrib1 VARCHAR(20) = NULL,
	@pStockAttrib2 VARCHAR(20) = NULL,
	@pStockAttrib3 VARCHAR(20) = NULL,
	@pPackingID VARCHAR(50) = NULL,
	@pMarkingCode varchar(20)=NULL,
	@pIsCheckBefRouteProdQty BIT = NULL,
	@pProdRouteHistNo VARCHAR(20) = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
	DECLARE @PONo VARCHAR(20) = @pPONo
	DECLARE @LineCode VARCHAR(20) = @pLineCode
	DECLARE @RouteCode VARCHAR(20) = @pRouteCode
	DECLARE @ProcessDateTime DATETIME = @pProcessDateTime
	DECLARE @DayPlanNo VARCHAR(20) = ISNULL(@pDayPlanNo,'')
	DECLARE @ControlNo VARCHAR(20) = ISNULL(@pControlNo,'')
	DECLARE @WorkerCode VARCHAR(20) = ISNULL(@pWorkerCode,'')
	DECLARE @MachineCode VARCHAR(20) = ISNULL(@pMachineCode,'')
	DECLARE @ProdQty NUMERIC(20,5) = ISNULL(@pProdQty,1)
	DECLARE @LotID VARCHAR(50) = ISNULL(@pLotID,'')
	DECLARE @LotNo VARCHAR(50) = ISNULL(@pLotNo,'')
	DECLARE @StockAttrib1 VARCHAR(20) = ISNULL(@pStockAttrib1,'')
	DECLARE @StockAttrib2 VARCHAR(20) = ISNULL(@pStockAttrib2,'')
	DECLARE @StockAttrib3 VARCHAR(20) = ISNULL(@pStockAttrib3,'')
	DECLARE @PackingID VARCHAR(50) = ISNULL(@pPackingID,'')
	DECLARE @MarkingCode VARCHAR(50) = ISNULL(@pMarkingCode,'') -- Mr.Duy add Ha nam factory
	DECLARE @SparePartLotID VARCHAR(30)    -- DinhManh update 2025-06-12
	DECLARE @IsCheckBefRouteProdQty BIT = ISNULL(@pIsCheckBefRouteProdQty,0)

	DECLARE @MaterialDocNo VARCHAR(20)
	DECLARE @CompanyCode VARCHAR(20)
	DECLARE @WorkCenterCode VARCHAR(20)
	DECLARE @MaterialCode VARCHAR(50)
	DECLARE @BomVersion VARCHAR(10)
	DECLARE @ProdRouteHistNo VARCHAR(20)
	DECLARE @BefRouteCode VARCHAR(20)
	DECLARE @RouteIndex INT
	DECLARE @IsInputRoute BIT
	DECLARE @IsOutputRoute BIT
	DECLARE @IsLineInput BIT
	DECLARE @ErrorMessage NVARCHAR(MAX)
	DECLARE @Barcode VARCHAR(50)
	--raiserror(@RouteCode,16,1)
	SELECT
			@CompanyCode = POI.CompanyCode,
			@WorkCenterCode = POI.WorkCenterCode,
			@MaterialCode = POI.MaterialCode,
			@BomVersion = POI.BomVersion,
			@IsInputRoute = POR.IsInputRoute,
			@IsOutputRoute = POR.IsOutputRoute,
			@RouteIndex = POR.RouteIndex
	FROM
			STB_ProductionOrderRouting POR
			INNER JOIN STB_ProductionOrderInfo POI
				ON POI.PONo = POR.PONo
	WHERE
			POR.PONo = @PONo AND
			POR.RouteCode = @RouteCode
			--raiserror(@RouteIndex,16,1)
	DECLARE @ShiftTime VARCHAR(20) = dbo.fnGetJobDateShiftTime(@ProcessDateTime,@CompanyCode, @WorkCenterCode,@LineCode,@RouteCode,NULL)
	DECLARE @JobDate DATE = SUBSTRING(@ShiftTime,1,8)
	DECLARE @ShiftCode VARCHAR(1) = SUBSTRING(@ShiftTime,9,1)
	DECLARE @TimeCode VARCHAR(2) = SUBSTRING(@ShiftTime,10,2)

	IF ISNULL(@RouteIndex,-1) >= 0 BEGIN	-- 실적처리 공정
			IF @ControlNo <> '' BEGIN		-- SetInfo 를 사용하면
					SELECT
							@Barcode = SI.Barcode,
							@IsLineInput = SI.IsLineInput
					FROM
							STB_SetInfo SI
					WHERE
							SI.ControlNo = @ControlNo

					IF @IsInputRoute = 0 AND @IsLineInput = 0 BEGIN
							EXEC SmartFramework.dbo.usp_GetAddonStringResource	@ProcessLanguage,
																				'^투입처리 되지 않은 바코드입니다^',
																				@ErrorMessage OUTPUT
							SET @ErrorMessage = @ErrorMessage + ' [%s]'
							RAISERROR(@ErrorMessage,16,1,@Barcode)
							RETURN
					END
			END

			IF @IsCheckBefRouteProdQty = 1 AND @IsInputRoute <> 1 BEGIN
					SELECT
							TOP 1
							@BefRouteCode = POR.RouteCode
					FROM
							STB_ProductionOrderRouting POR
					WHERE
							POR.PONo = @PONo AND
							POR.RouteIndex < @RouteIndex 
					ORDER BY
							POR.RouteIndex DESC
					--raiserror(@BefRouteCode,16,1)
					DECLARE @TotalQty NUMERIC(20,5)
					DECLARE @BefRouteQty NUMERIC(20,5)
					DECLARE @CurrentRouteQty NUMERIC(20,5)
					

					SELECT
							@CurrentRouteQty = SUM(PRH.ProdQty)
					FROM
							STB_ProdRouteHist PRH
					WHERE
							PRH.PONo = @PONo AND
							PRH.ControlNo = @ControlNo AND
							PRH.RouteCode = @RouteCode

					SELECT
							@BefRouteQty = SUM(PRH.ProdQty)
					FROM
							STB_ProdRouteHist PRH
					WHERE
							PRH.PONo = @PONo AND
							PRH.ControlNo = @ControlNo AND
							PRH.RouteCode = @BefRouteCode

					IF @RouteCode NOT IN ('E-28', 'V-28', 'V-28_BG','VE10', 'E-33', 'E-34', 'E-29', 'EM-03', 'M-06') 
					BEGIN -- 포장공정은 전공정의 실적을 초과할 수 있음. 절곡도요!

							--declare @test varchar(50) = @CurrentRouteQty
							--raiserror (@test,16,1)
						IF ISNULL(@CurrentRouteQty,0) + @ProdQty > ISNULL(@BefRouteQty,0) BEGIN
								EXEC SmartFramework.dbo.usp_GetAddonStringResource	@ProcessLanguage,
																					'^전공정의 수량을 초과할수 없습니다^',
																					@ErrorMessage OUTPUT
								DECLARE @BefStr VARCHAR(50) = CONVERT(VARCHAR,ISNULL(@BefRouteQty,0)) 
								DECLARE @Str VARCHAR(50) = CONVERT(VARCHAR,ISNULL(@CurrentRouteQty,0) + @ProdQty) + '/' + CONVERT(VARCHAR,ISNULL(@ProdQty,0))
								SET @ErrorMessage = @ErrorMessage + ' [%s] (' + @BefRouteCode + '/' + @BefStr + '-' + @RouteCode + '/' + @Str + ')'
								RAISERROR(@ErrorMessage,16,1,@Barcode)
								RETURN

						END
					END
			END

			SELECT
					@ProdRouteHistNo = PRH.ProdRouteHistNo
			FROM
					STB_ProdRouteHist PRH
			WHERE
					PRH.PONo = @PONo AND
					PRH.LineCode = @LineCode AND
					PRH.RouteCode = @RouteCode AND
					PRH.ControlNo = @ControlNo AND
					PRH.ProdDateTime = @ProcessDateTime

			IF ISNULL(@ProdRouteHistNo,'') = '' BEGIN		-- 재처리가 아니면 Insert
					SELECT
							@ProdRouteHistNo = PRH.ProdRouteHistNo
					FROM
							STB_ProdRouteHist PRH
					WHERE
							PRH.PONo = @PONo AND
							PRH.LineCode = @LineCode AND
							PRH.RouteCode = @RouteCode AND
							PRH.ControlNo = @ControlNo AND
							PRH.JobDate = @JobDate AND
							PRH.ShiftCode = @ShiftCode AND
							PRH.TimeCode = @TimeCode

					IF ISNULL(@ProdRouteHistNo,'') = '' BEGIN
							EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_ProdRouteHist',@ProdRouteHistNo OUTPUT

							INSERT INTO STB_ProcedureLog (ProcedureName, VariableName, VariableValue) 
								VALUES ('usp_DoProcessProdRouteHist', '@ProdRouteHistNo', @ProdRouteHistNo)

							UPDATE	STB_LineRouteMapping
							SET
									DayPlanNo = @DayPlanNo,
									ProdRouteHistNo = @ProdRouteHistNo
							WHERE
									LineCode = @LineCode AND
									RouteCode = @RouteCode

							INSERT INTO STB_ProdRouteHist
							(
								ProdRouteHistNo,
								CompanyCode,
								WorkCenterCode,
								PONo,
								DayPlanNo,
								ControlNo,
								MaterialCode,
								BomVersion,
								JobDate,
								ShiftCode,
								TimeCode,
								LineCode,
								RouteCode,
								WorkerCode,
								MachineCode,
								ProdQty,
								ProdDateTime,
								CreateDateTime,
								CreateUserID
							)
							VALUES
							(
								@ProdRouteHistNo,
								@CompanyCode,
								@WorkCenterCode,
								@PONo,
								@DayPlanNo,
								@ControlNo,
								@MaterialCode,
								@BomVersion,
								@JobDate,
								@ShiftCode,
								@TimeCode,
								@LineCode,
								@RouteCode,
								@WorkerCode,
								@MachineCode,
								@ProdQty,
								@ProcessDateTime,
								GETDATE(),
								@pProcessUserID
							)

							---- 신규 실적 ERP인터페이스 
							---- 실적처리 공정이면
							--IF EXISTS (SELECT 1 
							--			 FROM STB_ProdRouteHist PRH
							--			 LEFT OUTER JOIN STB_RouteInfo RI
							--			   ON PRH.RouteCode = RI.RouteCode
							--			WHERE PRH.ProdRouteHistNo = @ProdRouteHistNo
							--			  AND RI.IsInterfaceRoute = CONVERT(BIT, 1)
							--		) BEGIN
							--	exec usp_ProdRouteHist_itf @pProcessUserID, @pProcessLanguage, 'TEST', @ProdRouteHistNo, 'N'
							--END

							--작업자 추가
							IF @WorkerCode <> '' BEGIN
								EXEC usp_DoAddProdRouteHistByWorkerList	@pProcessUserID = @pProcessUserID,
															@pProcessLanguage = @pProcessLanguage,
															@pProdRouteHistNo = @ProdRouteHistNo,
															@pWorkerCode = @WorkerCode
							END
					END ELSE BEGIN
							UPDATE	STB_ProdRouteHist
							SET
									ProdQty = ProdQty + @ProdQty,
									ChangeDateTime = GETDATE(),
									ChangeUserID = @ProcessUserID
							WHERE
									ProdRouteHistNo = @ProdRouteHistNo

							-- 재작업 실적 ERP인터페이스 
							-- 실적처리 공정이면
							--IF EXISTS (SELECT 1 
							--			 FROM STB_ProdRouteHist PRH
							--			 LEFT OUTER JOIN STB_RouteInfo RI
							--			   ON PRH.RouteCode = RI.RouteCode
							--			WHERE PRH.ProdRouteHistNo = @ProdRouteHistNo
							--			  AND RI.IsInterfaceRoute = CONVERT(BIT, 1)
							--		) BEGIN
							--	exec usp_ProdRouteHist_itf @pProcessUserID, @pProcessLanguage, 'TEST', @ProdRouteHistNo, 'Y'
							--END
					END

					EXEC usp_DoProcessProdRouteSummary	@pCompanyCode = @CompanyCode,
														@pWorkCenterCode = @WorkCenterCode,
														@pLineCode = @LineCode,
														@pRouteCode = @RouteCode,
														@pPONo = @PONo,
														@pJobDate = @JobDate,
														@pShiftCode = @ShiftCode,
														@pTimeCode = @TimeCode,
														@pProdQty = @ProdQty

					
					
					-- 자재 차감
					EXEC usp_DoProcessProdGIMaterialByBOM	@pProcessUserID = @ProcessUserID,
															@pProcessLanguage = @ProcessLanguage,
															@pCompanyCode = @CompanyCode,
															@pWorkCenterCode = @WorkCenterCode,
															@pPONo = @PONo,
															@pLineCode = @LineCode,
															@pRouteCode = @RouteCode,
															@pMaterialCode = @MaterialCode,
															@pLotID = @LotID,
															@pLotNo = @LotNo,
															@pProdQty = @ProdQty,
															@pStockAttrib1 = @StockAttrib1,
															@pStockAttrib2 = @StockAttrib2,
															@pStockAttrib3 = @StockAttrib3,
															@pFPItemWorkNo = @ProdRouteHistNo

					IF @IsInputRoute = 1 BEGIN		-- 투입공정이면
							IF @ControlNo <> '' BEGIN		-- SetInfo를 사용하면
									IF @IsLineInput = 0 BEGIN
											UPDATE	STB_SetInfo
											SET
													IsLineInput = 1,
													InputDateTime = @ProcessDateTime,
													InputJobDate = @JobDate,
													InputLineCode = @LineCode,
													InputShiftCode = @ShiftCode
											WHERE
													ControlNo = @ControlNo



											-- DinhManh update 2025-06-12 to update LotID using by SparePartID
											EXEC usp_VN_UpdateSpecialSparePartLot	@pProcessUserID = @ProcessUserID,
																					@pProcessLanguage = @ProcessLanguage,
																					@pLineCode = @LineCode,
																					@pControlNo = @ControlNo

											-- End update --------------------------------------------------------------
									END
							END
					END

					IF @IsOutputRoute = 1 BEGIN		-- 마지막공정이면
							UPDATE	STB_ProductionOrderInfo
							SET
									ProdFinishQty = ISNULL(ProdFinishQty,0) + @ProdQty
							WHERE
									PONo = @PONo

							-- 출하검사 Lot?

							UPDATE	STB_SetInfo
							SET
									IsProdFinish = 1,
									ProdFinishDateTime = @ProcessDateTime,
									ProdFinishJobDate = @JobDate,
									ProdFinishShiftCode = @ShiftCode
							WHERE
									ControlNo = @ControlNo

							-- 생산입고 (Lot 생성)
							EXEC usp_DoProcessProdGRMaterialByOne	@pProcessUserID = @ProcessUserID,
																	@pProcessLanguage = @ProcessLanguage,
																	@pCompanyCode = @CompanyCode,
																	@pWorkCenterCode = @WorkCenterCode,
																	@pPONo = @PONo,
																	@pLineCode = @LineCode,
																	@pRouteCode = @RouteCode,
																	@pLotID = @LotID,
																	@pLotNo = @LotNo,
																	@pPackingID = @PackingID,
																	@pMarkingCode = @MarkingCode,
																	@pProdQty = @ProdQty,
																	@pStockAttrib1 = @StockAttrib1,
																	@pStockAttrib2 = @StockAttrib2,
																	@pStockAttrib3 = @StockAttrib3,
																	@pMaterialDocNo = @MaterialDocNo OUTPUT
							-- 입고완료			
							EXEC usp_DoFinishMaterialDoc	@pProcessLanguage = @ProcessLanguage,
															@pProcessUserID = @ProcessUserID,
															@pMaterialDocNo = @MaterialDocNo
							-- 입고확정
							EXEC usp_DoFixMaterialDoc	@pProcessUserID = @ProcessUserID,
														@pProcessLanguage = @ProcessLanguage,
														@pMaterialDocNo = @MaterialDocNo
					END
			END ELSE BEGIN		-- 재처리이면
					UPDATE	STB_ProdRouteHist
					SET
							DayPlanNo = @DayPlanNo,
							ControlNo = @ControlNo,
							JobDate = @JobDate,
							ShiftCode = @ShiftCode,
							TimeCode = @TimeCode,
							WorkerCode = @WorkerCode,
							ProdQty = @ProdQty
					WHERE
							ProdRouteHistNo = @ProdRouteHistNo
			END

			SET @pProdRouteHistNo = @ProdRouteHistNo
	END	--IF ISNULL(@RouteIndex,-1) >= 0 BEGIN	-- 실적처리 공정
END

