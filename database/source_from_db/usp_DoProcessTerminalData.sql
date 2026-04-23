
-- =============================================
-- Author:		Park Jong Seob (jspark@awoo.co.kr)
-- Create date: 2012.09.20
-- Description:	Process Terminal Data.
--				Error Number : 15  ==> Don`t retry queue. Remove queue. Just write log
--				Error Number : 16  ==> Retry queue. Don`t remove queue
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoProcessTerminalData]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pIPAddress VARCHAR(15),
	@pPortNo INT = NULL,
	@pData VARCHAR(MAX),
	@pIsRecovery VARCHAR(1) = NULL,
	@pProcessLogID BIGINT = NULL
AS
BEGIN
--	ROLLBACk
	DECLARE @DataType VARCHAR(20),
			@LineCode VARCHAR(20),
			@RouteCode VARCHAR(20),
			@MarkingCode VARCHAR(20),
			@DefectCauseID VARCHAR(100),
			@ProcessDateTime DATETIME,
			@DataPacket VARCHAR(MAX),
			@JobDateShiftTimeCode VARCHAR(10),
			@JobDate DATE,
			@ShiftCode VARCHAR(1),
			@TimeCode VARCHAR(1),
			@E_MSG VARCHAR(MAX),
			@E_NO INT,
			@ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage
			
	DECLARE @CompanyCode VARCHAR(20),
			@WorkCenterCode VARCHAR(20),	
			@Sequence uniqueidentifier

	DECLARE @ContinueDataSeq BIGINT
			
	DECLARE @SQLText NVARCHAR(MAX)

	DECLARE @ProcessingStartTime DATETIME,
			@ProcessingEndTime DATETIME,
			@ProcessLogID BigINT	
	
	SET @ProcessingStartTime = GETDATE()	
	
	
	IF @pIsRecovery IS NULL
	BegIn
		SET @pIsRecovery = 'N'
	END
		
	IF @pIsRecovery = 'N'
	BEGIN
			INSERT INTO STB_ProcessTerminalDataLog
				(IPAddress, PortNo, Data, ProcessResult, ProcessDateTime)
			VALUES
				(@pIPAddress, @pPortNo, @pData, 'ING', @ProcessingStartTime)
			
			SELECT @ProcessLogID = IDENT_CURRENT('STB_ProcessTerminalDataLog')	
									
	END ELSE BEGIN
		SET @ProcessLogID = @pProcessLogID

		UPDATE STB_ProcessTerminalDataLog
		SET
			ProcessResult = 'ING',
			ProcessDateTime = @ProcessingStartTime
		WHERE
			ProcessIndex = @ProcessLogID		
	END

	
	BEGIN TRY
			SET @DataType = RTRIM(SUBSTRING(@pData, 1, 20))
			SET @LineCode = RTRIM(SUBSTRING(@pData, 21, 20))
			SET @RouteCode = RTRIM(SUBSTRING(@pData, 41, 20))
			SET @ProcessDateTime = SmartFramework.dbo.fnConvertVarcharToDateTime('yyyymmddhhmissfff',SUBSTRING(@pData, 61, 17))
			SET @DataPacket	= SUBSTRING(@pData, 78, LEN(@pData) - 77)
		
	END TRY
	BEGIN CATCH
			UPDATE STB_ProcessTerminalDataLog
			SET
				ProcessResult = 'NG : Parsing Error' ,
				EventDateTime = GETDATE()
			WHERE
				ProcessIndex = @ProcessLogID		
			
			RAISERROR('NG : Parsing Error', 15, 1)
			
			RETURN
	END CATCH
			--RAISERROR(@DataPacket, 16, 1)
			
		--	RETURN
	SELECT
			@CompanyCode = LI.CompanyCode,
			@WorkCenterCode = LI.WorkCenterCode
	FROM
			STB_LineInfo LI
	WHERE
			LI.LineCode = @LineCode
	

	--SET @JobDateShiftTimeCode = dbo.fnGetJobDateShiftTime(@ProcessDateTime, @CompanyCode, @WorkCenterCode, @LineCode, @RouteCode, '', '')
	SET @JobDate = CONVERT(DATE, LEFT(@JobDateShiftTimeCode, 8), 112)
	SET @ShiftCode = SUBSTRING(@JobDateShiftTimeCode, 9, 1)
	SET @TimeCode = SUBSTRING(@JobDateShiftTimeCode, 10, 1)

	DECLARE @Barcode VARCHAR(50),
			@ModelCode VARCHAR(50),
			@PartType VARCHAR(20),
			@PartSeq VARCHAR(4),
			@MaterialCode VARCHAR(50),
			@PartBarcode VARCHAR(30),
			@TestItemCode VARCHAR(20),
			@TestItemSub VARCHAR(20),
			@TestResult VARCHAR(10),
			@Measure1 VARCHAR(20),
			@Measure2 VARCHAR(20) = '',
			@Measure3 VARCHAR(20) = '',
			@MeasureStartTime DATETIME,
			@MeasureEndTime DATETIME,
			@MeasureData VARCHAR(MAX),
			@MeasureQty INT,
			@DefectCode VARCHAR(20),
			@MeasureResult BIT,
			@IsNewMeasureData BIT,
			@ControlNo VARCHAR(20),
			@LabelType VARCHAR(20),
			@StrProdQty VARCHAR(50),
			@ProdQty NUMERIC(20,5),
			@LotID VARCHAR(50),
			@LotNo VARCHAR(50),
			@WorkerCode VARCHAR(20),
			@PackingID VARCHAR(50),
			@StockAttrib1 VARCHAR(20),
			@MachineCode VARCHAR(20),
			-- 불량비고 추가
			@DRIExtText02 NVARCHAR(400),
			@DefectSummaryNo VARCHAR(20)

	BEGIN TRY	
		BEGIN TRAN
		
		IF @DataType = 'PRODROUTE' BEGIN		-- 공정실적
				SET @Barcode = RTRIM(SUBSTRING(@DataPacket,1,50))
				SET @WorkerCode = RTRIM(SUBSTRING(@DataPacket,51,20))
				SET @LotID = RTRIM(SUBSTRING(@DataPacket,71,50))
				SET @LotNo = RTRIM(SUBSTRING(@DataPacket,121,50))
				SET @MachineCode = RTRIM(SUBSTRING(@DataPacket,171,20))
				SET @StrProdQty = RTRIM(SUBSTRING(@DataPacket,191,10))
				IF ISNUMERIC(@StrProdQty) = 1 BEGIN
						SET @ProdQty = @StrProdQty
				END

				EXEC usp_DoProcessProdRouteHistForBarcode	
				                                            @pProcessUserID = @ProcessUserID,
															@pProcessLanguage = @ProcessLanguage,
															@pBarcode = @Barcode,
															@pLineCode = @LineCode,
															@pRouteCode = @RouteCode,
															@pWorkerCode = @WorkerCode,
															@pProdQty = @ProdQty,
															@pLotID = @LotID,
															@pLotNo = @LotNo,
															@pMachineCode = @MachineCode,
															@pIsCheckBefRouteProdQty = 1,
															@pProcessDateTime = @ProcessDateTime

		END ELSE IF @DataType = 'PRODDEFECT' BEGIN		-- 불량등록 				
				SET @Barcode = RTRIM(SUBSTRING(@DataPacket,1,50))
				SET @DefectCode = RTRIM(SUBSTRING(@DataPacket,51,20))
				SET @ProdQty = SUBSTRING(@DataPacket,71,10)
				-- 불량비고 추가
				SET @DRIExtText02 = SUBSTRING(@DataPacket,81,400)
				SET @MarkingCode = RTRIM(SUBSTRING(@DataPacket,401,20))
				SET @DefectCauseID=RTRIM(SUBSTRING(@DataPacket,421,100))

				EXEC usp_DoProcessDefectRepairInfoByBarcode	@pProcessUserID = @ProcessUserID,
															@pProcessLanguage = @ProcessLanguage,
															@pLineCode = @LineCode,
															@pRouteCode = @RouteCode,
															@pBarcode = @Barcode,
															@pDefectCode = @DefectCode,
															@pDefectQty = @ProdQty,
															@pProcessDateTime = @ProcessDateTime,
															@pMarkingCode = @MarkingCode,
															@pDefectCauseID=@DefectCauseID,
															@pDefectSummaryNo = @DefectSummaryNo OUTPUT

				-- 불량비고 입력
				IF @DefectSummaryNo IS NOT NULL AND RTRIM(@DRIExtText02) <> '' BEGIN

				--đoạn này------------------------------
					UPDATE STB_DefectRepairInfo
					   SET DRIExtText02 = @DRIExtText02
					 WHERE DefectSummaryNo = @DefectSummaryNo
				END

		END ELSE IF @DataType = 'PRODPACKING' BEGIN		-- 패킹공정
				SET @Barcode = RTRIM(SUBSTRING(@DataPacket,1,50))
				SET @WorkerCode = RTRIM(SUBSTRING(@DataPacket,51,20))
				SET @LotID = RTRIM(SUBSTRING(@DataPacket,71,50))
				SET @LotNo = RTRIM(SUBSTRING(@DataPacket,121,50))
				SET @MachineCode = RTRIM(SUBSTRING(@DataPacket,171,20))
				SET @StrProdQty = RTRIM(SUBSTRING(@DataPacket,191,10))
				SET @PackingID = RTRIM(SUBSTRING(@DataPacket,201,50))
				SET @StockAttrib1 = RTRIM(SUBSTRING(@DataPacket,251,20))
				SET @MarkingCode = RTRIM(SUBSTRING(@DataPacket,271,20))
				SET @ProdQty = CONVERT(NUMERIC(20,5),@StrProdQty)
				-----------------------------
				--declare @MaterialCode1 varchar(20);
				--select @MaterialCode1= MaterialCode from STB_SetInfo WHERE Barcode = @Barcode
				--IF (@Barcode NOT LIKE 'M%')  AND (@MaterialCode1 NOT IN (
				--												   'VNVEL38-004', 'VECV30-051', 'VHCV23-004', 'VVVEC30-056',
				--												   'VNVEC30-039', 'PECVT30-104', 'VNVEL38-001', 'VNVEL38-002',
				--												   'VVVEC27-025', 'VVVEC30-054', 'VVVEC30-032', 'VSVVVEC30-032',
				--												   'VVVEC30-052', 'S35626S-01', 'VVVEC30-S01', 'VVVEC30-058',
				--												   'VVVEC30-S02', 'VVVEC30-037', 'VVVEC27-028', 'VNVEC30-035',
				--												   'VVVEC30-053', 'VVVEC30-S56', 'VVVEC30-043', 'LSECVT30-076',
				--												   'VVVEC30-038', 'VVVEC30-046', 'VVVET27-002', 'VVVEC30-060',
				--												   'VNVEL38-003', 'MVCE160-001', 'VNVEL38-005', 'VNVEL38-006'
				--											   ))
				--		begin
				--				Declare @DecisionResult varchar(20);
				--					select @DecisionResult=DecisionResult from STB_MaterialQcInfo MQI where  MQI.MaterialQcNo IN (SELECT LotNumber   FROM STB_SetInfo WHERE Barcode = @Barcode)

				--					INSERT INTO CheckTable (Barcode, DecisionResult,PackingID)
				--					VALUES (@Barcode, @DecisionResult,@PackingID)
				--					declare @CheckPass int=0;
				--					IF EXISTS (
				--						SELECT 1
				--						FROM CheckTable
				--						WHERE DecisionResult not LIKE 'pass' and PackingID=@PackingID
				--					)begin
				--							set @CheckPass=1
				--					end

				--					if(@CheckPass=1)
				--						begin	
				--								RAISERROR(N'ton tai ma OQC chua pass',16,1)
				--						end
					
				--					else
				--						begin
				--									INSERT INTO STB_ProcedureLog (ProcedureName, VariableName, VariableValue) 
				--									VALUES ('usp_DoProcessTerminalData', '@Barcode', @Barcode)
				--								EXEC usp_DoProcessProdRouteHistForBarcode	@pProcessUserID = @ProcessUserID,
				--													@pProcessLanguage = @ProcessLanguage,
				--													@pBarcode = @Barcode,
				--													@pLineCode = @LineCode,
				--													@pRouteCode = @RouteCode,
				--													@pWorkerCode = @WorkerCode,
				--													@pProdQty = @StrProdQty,
				--													@pLotID = @LotID,
				--													@pLotNo = @LotNo,
				--													@pStockAttrib1 = @StockAttrib1,
				--													@pPackingID = @PackingID,
				--													@pIsCheckBefRouteProdQty = 1,
				--													@pProcessDateTime = @ProcessDateTime
				--						end
								
				--		end
				--else
				--		begin
				--					INSERT INTO STB_ProcedureLog (ProcedureName, VariableName, VariableValue) 
				--				VALUES ('usp_DoProcessTerminalData', '@Barcode', @Barcode)

				--				EXEC usp_DoProcessProdRouteHistForBarcode	@pProcessUserID = @ProcessUserID,
				--															@pProcessLanguage = @ProcessLanguage,
				--															@pBarcode = @Barcode,
				--															@pLineCode = @LineCode,
				--															@pRouteCode = @RouteCode,
				--															@pWorkerCode = @WorkerCode,
				--															@pProdQty = @StrProdQty,
				--															@pLotID = @LotID,
				--															@pLotNo = @LotNo,
				--															@pStockAttrib1 = @StockAttrib1,
				--															@pPackingID = @PackingID,
				--															@pIsCheckBefRouteProdQty = 1,
				--															@pProcessDateTime = @ProcessDateTime
							
				--		end
				
			
		
				----------------------------------------
				INSERT INTO STB_ProcedureLog (ProcedureName, VariableName, VariableValue) 
								VALUES ('usp_DoProcessTerminalData', '@Barcode', @Barcode)

				EXEC usp_DoProcessProdRouteHistForBarcode	@pProcessUserID = @ProcessUserID,
															@pProcessLanguage = @ProcessLanguage,
															@pBarcode = @Barcode,
															@pLineCode = @LineCode,
															@pRouteCode = @RouteCode,
															@pWorkerCode = @WorkerCode,
															@pProdQty = @StrProdQty,
															@pLotID = @LotID,
															@pLotNo = @LotNo,
															@pStockAttrib1 = @StockAttrib1,
															@pPackingID = @PackingID,
															@pIsCheckBefRouteProdQty = 1,
															@pProcessDateTime = @ProcessDateTime,
															@pMarkingCode = @MarkingCode
----------------------------------------------------------------------------------------------
		END ELSE IF @DataType = 'INSPECTION' BEGIN
				PRINT ''
					
		END ELSE IF @DataType = 'MEASURE' BEGIN		
				PRINT ''
		END ELSE IF @DataType = 'DEFECT' BEGIN
				PRINT ''
		END

		
		COMMIT TRAN


		UPDATE STB_ProcessTerminalDataLog
		SET
			EventDateTime = @ProcessDateTime,
			ProcessResult = 'OK'
		WHERE
			ProcessIndex = @ProcessLogID	
			
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		SET @E_MSG = ERROR_MESSAGE()
		SET @E_NO = ERROR_NUMBER()
			
		UPDATE STB_ProcessTerminalDataLog
		SET
			EventDateTime = @ProcessDateTime,
			ProcessResult = 'ERROR : ' + @E_MSG
		WHERE
			ProcessIndex = @ProcessLogID	
				
		
		--IF @E_NO = 2627
		--BEGIN
		--	RAISERROR('ERROR : (WILL RETRY) %s ', 16, 1, @E_MSG)		
		--END ELSE BEGIN
		--	RAISERROR('ERROR : %s', 15, 1, @E_MSG)
		--END
		-- 게더링 미사용으로 STB_ProcessTerminalDataLog 에 기록하고 RAISERROR를 발생한다.
		RAISERROR(@E_MSG,16,1)				
		
	END CATCH		
		


	RETURN

END

--             select * from CheckTable
--delete from CheckTable