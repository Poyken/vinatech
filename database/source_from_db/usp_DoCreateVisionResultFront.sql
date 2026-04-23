-- 날짜별 vision result 생성
CREATE proc [dbo].[usp_DoCreateVisionResultFront]
	@pProcessUserID VARCHAR(20)
   ,@pProcessLanguage VARCHAR(20)
   ,@pLotNo VARCHAR(20)
   ,@pSheetCnt INT = 100
AS
BEGIN
	Declare @LotNo VARCHAR(20) = @pLotNo
	       ,@SheetCnt INT = @pSheetCnt
		   ,@DefectRate NUMERIC(20,5) = 15+(rand() *5)
		   ,@LoopCnt INT = 0
		   ,@ResultNo BIGINT 
		   ,@InspectionStartDateTime DATETIME = DATEADD(minute, 5, dbo.fnConvertVarcharToDateTime('yyyymmddhhmiss', @pLotNo))
		   ,@DecisionDateTime DATETIME

	Declare @BarcodeHeader VARCHAR(8) = LEFT(@LotNo, 8) + '01'
	Declare @NGCnt INT = CONVERT(INT, CONVERT(NUMERIC(20,5), @SheetCnt) * @DefectRate / 100)

	-- SheetBarcode 조립 및 데이터 입력
	INSERT INTO STB_VisionInspectionResult (MachineID, LotNo, Barcode, ModelNo, PannelID
										   ,DecisionResult, DefectNo, DotBlackType, LineBlackType, MuraBlackType
										   ,DotWhiteType, LineWhiteType, MuraWhiteType, ExtenedType, etc
										   ,DecisionDateTime, Pitch, SheetSize)
			SELECT 'VNMP07001', @LotNo, @BarcodeHeader + RIGHT('000000' + CONVERT(VARCHAR, num), 6), @BarcodeHeader + RIGHT('000000' + CONVERT(VARCHAR, num), 6), num
			      ,'GOOD', 0, 0, 0, 0
				  ,0, 0, 0, 0, 0
				  ,DATEADD(second, CONVERT(INT, 5 + (rand() * 5)), dbo.fnConvertVarcharToDateTime('yyyymmddhhmiss', @LotNo)), 'Pitch: ' + LEFT(CONVERT(VARCHAR(20), 107 + rand()), 6)
				  ,'PS: ' + LEFT(CONVERT(VARCHAR(20), (156 + rand())), 6) +  ' x ' + LEFT(CONVERT(VARCHAR(20), (101 + rand())), 6)
			  FROM dbo.fnSequenceTable(@SheetCnt)
			  option (MAXRECURSION 0)

	-- NG 업데이트
	PRINT '@NGCnt ::::: ' + CONVERT(VARCHAR, @NGCnt)

	WHILE @LoopCnt < @NGCnt BEGIN

		SELECT TOP 1 @ResultNo = ResultNo 
		  FROM STB_VisionInspectionResult
		 WHERE LotNo = @LotNo
		   AND DecisionResult = 'GOOD'
		 ORDER BY newid()


		UPDATE STB_VisionInspectionResult
		   SET DecisionResult = 'NG'
		 WHERE ResultNo = @ResultNo

		SET @LoopCnt = @LoopCnt + 1
	END

	-- 불량수량 업데이트(시트당 1~10개 안팍)
	DECLARE cur CURSOR FOR

	SELECT ResultNo
	  FROM STB_VisionInspectionResult
	 WHERE LotNo = @LotNo
	   AND DecisionResult = 'NG'

	OPEN cur

	FETCH NEXT FROM cur INTO @ResultNo

	WHILE @@FETCH_STATUS = 0
	BEGIN
		UPDATE STB_VisionInspectionResult
		   SET DefectNo = CONVERT(INT, (rand() * 8) + 5)
		 WHERE ResultNo = @ResultNo

		UPDATE STB_VisionInspectionResult
		   SET DotBlackType = CONVERT(INT, rand() * 4)
		 WHERE ResultNo = @ResultNo

		UPDATE STB_VisionInspectionResult
		   SET DotWhiteType = CONVERT(INT, CONVERT(NUMERIC(20,5), (DefectNo - DotBlackType)) * 0.6)
		 WHERE ResultNo = @ResultNo

		UPDATE STB_VisionInspectionResult
		   SET LineWhiteType = CONVERT(INT, CONVERT(NUMERIC(20,5), (DefectNo - DotBlackType)) * 0.4)
		 WHERE ResultNo = @ResultNo 

		UPDATE STB_VisionInspectionResult
		   SET ExtenedType = DefectNo - (DotBlackType + DotWhiteType + LineWhiteType)
		 WHERE ResultNo = @ResultNo
	
		FETCH NEXT FROM cur INTO @ResultNo
	END

	CLOSE cur
	DEALLOCATE cur

	-- 판정일시, 생성일시 업데이트
	-- 불량항목 발생여부 업데이트
	DECLARE cur2 CURSOR FOR

	SELECT ResultNo
	  FROM STB_VisionInspectionResult
	 WHERE LotNo = @LotNo
	 ORDER BY Barcode

	OPEN cur2

	FETCH NEXT FROM cur2 INTO @ResultNo

	WHILE @@FETCH_STATUS = 0
	BEGIN
		-- 판정일시
		UPDATE STB_VisionInspectionResult
		   SET DecisionDateTime = DATEADD(second, (9 * CONVERT(INT, PannelID)) + (rand() * 2), @InspectionStartDateTime) 
		 WHERE ResultNo = @ResultNo
	
		FETCH NEXT FROM cur2 INTO @ResultNo
	END

	CLOSE cur2
	DEALLOCATE cur2

	-- CreateDateTime : 검사시작일시 + (12 * 시트수)로 일괄 업데이트
	UPDATE STB_VisionInspectionResult
	   SET CreateDateTime = DATEADD(second, 12 * @SheetCnt, @InspectionStartDateTime)
	 WHERE LotNo = @LotNo

	-- 각 불량항목 업데이트


	-- CS문자열 업데이트
	UPDATE STB_VisionInspectionResult
	   SET SheetSize = SheetSize + ' [' + REPLACE(SheetSize, 'PS', 'CS') + ']'
	 WHERE LotNo = @LotNo
END