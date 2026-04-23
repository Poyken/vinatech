-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-10-05
-- Browsable : true
-- Group : 품질관리
-- Description:	
-- Modified:
-- ToDo : STB_SetInfo 에 존재하는 Lot의 경우 ProdNo와 RefDoc를 가져오도록 변경
-- =============================================
CREATE PROCEDURE usp_DoCreateElectrodeRouteInspHist
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)
AS
BEGIN
	Declare @ElectrodeRouteInspHistNo VARCHAR(20)
		   ,@MeasureDate DATETIME
		   ,@MaterialCode VARCHAR(20)
		   ,@MaterialName NVARCHAR(400)
		   ,@Barcode VARCHAR(20)
		   ,@REQ_A011 NUMERIC(20,5)
		   ,@REQ_A021 NUMERIC(20,5)
		   ,@REQ_A031 NUMERIC(20,5)
		   ,@REQ_A012 NUMERIC(20,5)
		   ,@REQ_A022 NUMERIC(20,5)
		   ,@REQ_A032 NUMERIC(20,5)
		   ,@REQ_A013 NUMERIC(20,5)
		   ,@REQ_A023 NUMERIC(20,5)
		   ,@REQ_A033 NUMERIC(20,5)
		   ,@REQ_W01 NUMERIC(20,5)
		   ,@REQ_W02 NUMERIC(20,5)
		   ,@REQ_W03 NUMERIC(20,5)
		   ,@REQ_E01 BIT
		   ,@REQ_E02 BIT
		   ,@REQ_E03 BIT
		   ,@Remark NVARCHAR(MAX)
		   ,@InspWorkerCode VARCHAR(20)
		   ,@InspWorkerName NVARCHAR(100)
		   ,@CreateDateTime DATETIME
		   ,@ProcessDateTime DATETIME
		   -- 추가변수
		   ,@CommInspDocNo VARCHAR(20)
		   ,@CommInspMeasureNo VARCHAR(20)
		   ,@CommInspItemCode VARCHAR(20)
		   ,@CommInspDocItemNo VARCHAR(20)
		   ,@PONo VARCHAR(20)
		   ,@ControlNo VARCHAR(20)

	-- 커서 1 : 대상건 조회
	DECLARE curMain CURSOR FOR

		SELECT TOP 1 ERIH.ElectrodeRouteInspHistNo
			  ,ERIH.MeasureDate
			  ,ERIH.MaterialCode
			  ,ERIH.MaterialName
			  ,ERIH.Barcode
			  ,ERIH.REQ_A011
			  ,ERIH.REQ_A021
			  ,ERIH.REQ_A031
			  ,ERIH.REQ_A012
			  ,ERIH.REQ_A022
			  ,ERIH.REQ_A032
			  ,ERIH.REQ_A013
			  ,ERIH.REQ_A023
			  ,ERIH.REQ_A033
			  ,ERIH.REQ_W01
			  ,ERIH.REQ_W02
			  ,ERIH.REQ_W03
			  ,ERIH.REQ_E01
			  ,ERIH.REQ_E02
			  ,ERIH.REQ_E03
			  ,ERIH.Remark
			  ,ERIH.InspWorkerCode
			  ,ERIH.InspWorkerName
			  ,ERIH.CreateDateTime
			  ,ERIH.ProcessDateTime
		  FROM STB_ElectrodeRouteInspHist ERIH
		 WHERE ERIH.ProcessDateTime IS NULL
		   AND ERIH.MaterialCode IS NOT NULL
		 ORDER BY ERIH.ElectrodeRouteInspHistNo


	OPEN curMain

	FETCH NEXT FROM curMain INTO @ElectrodeRouteInspHistNo
			                    ,@MeasureDate
								,@MaterialCode
			                    ,@MaterialName
			                    ,@Barcode
			                    ,@REQ_A011
			                    ,@REQ_A021
			                    ,@REQ_A031
			                    ,@REQ_A012
			                    ,@REQ_A022
			                    ,@REQ_A032
			                    ,@REQ_A013
			                    ,@REQ_A023
			                    ,@REQ_A033
			                    ,@REQ_W01
			                    ,@REQ_W02
			                    ,@REQ_W03
			                    ,@REQ_E01
			                    ,@REQ_E02
			                    ,@REQ_E03
			                    ,@Remark
								,@InspWorkerCode
			                    ,@InspWorkerName
			                    ,@CreateDateTime
			                    ,@ProcessDateTime

	WHILE @@FETCH_STATUS = 0
	BEGIN
		-- SetInfo 
		SELECT @PONo = PONo
		      ,@ControlNo = ControlNo
		  FROM STB_SetInfo
		 WHERE Barcode = @Barcode

		-- usp_DoCreateCommInspDocHistory, usp_DoCreateCommInspDocItem 생성
		EXEC usp_DoCreateCommInspDocHistoryFromDate	@pProcessLanguage = @pProcessLanguage,
											@pProcessUserID = @pProcessUserID,
											@pCommInspTypeCode = 'ROUTE_ELECTRODE_QUALITY',
											@pCompanyCode = 'VNT',
											@pWorkCenterCode = 'VNT_F1',
											@pRefDoc = @PONo,
											@pProdNo = @ControlNo,
											@pProductGroupCode = '',
											@pMaterialCode = @MaterialCode,
											@pLineCode = '',
											@pRouteCode = '',
											@pMachineCode = '',
											@pMoldNumber = '',
											@pCategoryName = '',
											@pMeasureDate = @MeasureDate,
											@pCommInspDocNo = @CommInspDocNo OUTPUT
		-- 커서 2 : 측정데이터입력
		-- STB_CommInspDocItem : CommInspDocNo
			DECLARE cur CURSOR FOR

			SELECT CommInspItemCode
			      ,CommInspDocItemNo
			  FROM STB_CommInspDocItem
			 WHERE CommInspDocNo = @CommInspDocNo


			OPEN cur

			FETCH NEXT FROM cur INTO @CommInspItemCode, @CommInspDocItemNo

			WHILE @@FETCH_STATUS = 0
			BEGIN
				IF @CommInspItemCode = 'REQ_A01' BEGIN
					--두께(좌) #1
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
					SELECT @CommInspMeasureNo
					      ,@CommInspDocItemNo
						  ,1
						  ,NULL
						  ,@REQ_A011
						  ,'OK'
						  ,GETDATE()
						  ,'eai'
						  ,@InspWorkerCode

					--두께(좌) #2
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
					SELECT @CommInspMeasureNo
					      ,@CommInspDocItemNo
						  ,2
						  ,NULL
						  ,@REQ_A012
						  ,'OK'
						  ,GETDATE()
						  ,'eai'
						  ,@InspWorkerCode

					--두께(좌) #3
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
					SELECT @CommInspMeasureNo
					      ,@CommInspDocItemNo
						  ,3
						  ,NULL
						  ,@REQ_A013
						  ,'OK'
						  ,GETDATE()
						  ,'eai'
						  ,@InspWorkerCode

				END

				IF @CommInspItemCode = 'REQ_A02' BEGIN
					--두께(중) #1
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
					SELECT @CommInspMeasureNo
					      ,@CommInspDocItemNo
						  ,1
						  ,NULL
						  ,@REQ_A021
						  ,'OK'
						  ,GETDATE()
						  ,'eai'
						  ,@InspWorkerCode

					--두께(중) #2
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
					SELECT @CommInspMeasureNo
					      ,@CommInspDocItemNo
						  ,2
						  ,NULL
						  ,@REQ_A022
						  ,'OK'
						  ,GETDATE()
						  ,'eai'
						  ,@InspWorkerCode

					--두께(중) #3
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
					SELECT @CommInspMeasureNo
					      ,@CommInspDocItemNo
						  ,3
						  ,NULL
						  ,@REQ_A023
						  ,'OK'
						  ,GETDATE()
						  ,'eai'
						  ,@InspWorkerCode

				END

				IF @CommInspItemCode = 'REQ_A03' BEGIN
					--두께(우) #1
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
					SELECT @CommInspMeasureNo
					      ,@CommInspDocItemNo
						  ,1
						  ,NULL
						  ,@REQ_A031
						  ,'OK'
						  ,GETDATE()
						  ,'eai'
						  ,@InspWorkerCode

					--두께(우) #2
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
					SELECT @CommInspMeasureNo
					      ,@CommInspDocItemNo
						  ,2
						  ,NULL
						  ,@REQ_A032
						  ,'OK'
						  ,GETDATE()
						  ,'eai'
						  ,@InspWorkerCode

					--두께(우) #3
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
					SELECT @CommInspMeasureNo
					      ,@CommInspDocItemNo
						  ,3
						  ,NULL
						  ,@REQ_A033
						  ,'OK'
						  ,GETDATE()
						  ,'eai'
						  ,@InspWorkerCode

				END

				-- 무게 좌
				IF @CommInspItemCode = 'REQ_W01' BEGIN
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
					SELECT @CommInspMeasureNo
					      ,@CommInspDocItemNo
						  ,1
						  ,NULL
						  ,@REQ_W01
						  ,'OK'
						  ,GETDATE()
						  ,'eai'
						  ,@InspWorkerCode
				END

				-- 무게 중
				IF @CommInspItemCode = 'REQ_W02' BEGIN
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
					SELECT @CommInspMeasureNo
					      ,@CommInspDocItemNo
						  ,1
						  ,NULL
						  ,@REQ_W02
						  ,'OK'
						  ,GETDATE()
						  ,'eai'
						  ,@InspWorkerCode
				END

				-- 무게 우
				IF @CommInspItemCode = 'REQ_W03' BEGIN
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
					SELECT @CommInspMeasureNo
					      ,@CommInspDocItemNo
						  ,1
						  ,NULL
						  ,@REQ_W03
						  ,'OK'
						  ,GETDATE()
						  ,'eai'
						  ,@InspWorkerCode
				END


				IF @CommInspItemCode = 'REQ_E01' BEGIN
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
					SELECT @CommInspMeasureNo
					      ,@CommInspDocItemNo
						  ,1
						  ,NULL
						  ,0.0
						  ,CONVERT(INT, @REQ_E01)
						  ,GETDATE()
						  ,'eai'
						  ,@InspWorkerCode
				END

				IF @CommInspItemCode = 'REQ_E02' BEGIN
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
					SELECT @CommInspMeasureNo
					      ,@CommInspDocItemNo
						  ,1
						  ,NULL
						  ,0.0
						  ,CONVERT(INT, @REQ_E02)
						  ,GETDATE()
						  ,'eai'
						  ,@InspWorkerCode
				END

				IF @CommInspItemCode = 'REQ_E03' BEGIN
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
					SELECT @CommInspMeasureNo
					      ,@CommInspDocItemNo
						  ,1
						  ,NULL
						  ,0.0
						  ,CONVERT(INT, @REQ_E03)
						  ,GETDATE()
						  ,'eai'
						  ,@InspWorkerCode
				END

				-- 프로세스처리일 업데이트
				UPDATE STB_ElectrodeRouteInspHist
				   SET ProcessDateTime = GETDATE()
				 WHERE ElectrodeRouteInspHistNo = @ElectrodeRouteInspHistNo
	
				FETCH NEXT FROM cur INTO @CommInspItemCode, @CommInspDocItemNo
			END

			CLOSE cur
			DEALLOCATE cur

			-- 비고, 전극Lot 업데이트
			UPDATE STB_CommInspDocHistory
			   SET CIDHExtText02 = @Remark
			      ,ElectrodeLotNumber = @Barcode
			 WHERE CommInspDocNo = @CommInspDocNo

	
		FETCH NEXT FROM curMain INTO @ElectrodeRouteInspHistNo
			                    ,@MeasureDate
								,@MaterialCode
			                    ,@MaterialName
			                    ,@Barcode
			                    ,@REQ_A011
			                    ,@REQ_A021
			                    ,@REQ_A031
			                    ,@REQ_A012
			                    ,@REQ_A022
			                    ,@REQ_A032
			                    ,@REQ_A013
			                    ,@REQ_A023
			                    ,@REQ_A033
			                    ,@REQ_W01
			                    ,@REQ_W02
			                    ,@REQ_W03
			                    ,@REQ_E01
			                    ,@REQ_E02
			                    ,@REQ_E03
			                    ,@Remark
								,@InspWorkerCode
			                    ,@InspWorkerName
			                    ,@CreateDateTime
			                    ,@ProcessDateTime
	END

	CLOSE curMain
	DEALLOCATE curMain
END