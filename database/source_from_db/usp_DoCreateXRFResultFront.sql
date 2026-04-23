CREATE proc [dbo].[usp_DoCreateXRFResultFront]
	@pProcessUserID VARCHAR(20)
   ,@pProcessLanguage VARCHAR(20)
   ,@pLotNo VARCHAR(20)
   ,@pSheetCnt INT = 100
AS
BEGIN
	Declare @LotNo VARCHAR(20) = @pLotNo
	       ,@SheetCnt INT = @pSheetCnt
		   ,@LoopCnt INT = 0
		   ,@InspectionNo BIGINT 
		   ,@InspectionStartDateTime DATETIME = DATEADD(minute, 4, dbo.fnConvertVarcharToDateTime('yyyymmddhhmiss', @pLotNo))
		   ,@LogDateTime DATETIME
		   ,@Result1 NUMERIC(20,5)

	Declare @BarcodeHeader VARCHAR(8) = LEFT(@LotNo, 8) + '01'

	-- SheetBarcode 조립 및 데이터 입력(전면)
	INSERT INTO STB_XRFInspectionInfo (MachineID, LotNo, Barcode, Idx, RunTime
										   ,Detector, Result1, Result2, Result3, LogDateTime)
			SELECT 'VNMP07001', @LotNo, @BarcodeHeader + RIGHT('000000' + CONVERT(VARCHAR, num), 6), num, 9000
			      ,'D1', 0.45, 0, 0, GETDATE()
			  FROM dbo.fnSequenceTable(@SheetCnt)
			  ORDER BY num ASC
			  option (MAXRECURSION 0)

	-- 런타임 및 결과값 업데이트
	DECLARE cur CURSOR FOR

	SELECT InspectionNo
	  FROM STB_XRFInspectionInfo
	 WHERE LotNo = @LotNo
	 ORDER BY InspectionNo

	OPEN cur

	FETCH NEXT FROM cur INTO @InspectionNo

	WHILE @@FETCH_STATUS = 0
	BEGIN
		-- Runtime
		UPDATE STB_XRFInspectionInfo
		   SET RunTime = CONVERT(INT, (rand() * 200) + 9000)
		 WHERE InspectionNo = @InspectionNo

		-- Result1
		UPDATE STB_XRFInspectionInfo
		   SET Result1 = Result1 + (rand() * 0.005 + 0.001)
		 WHERE InspectionNo = @InspectionNo

		-- LogDateTime
		UPDATE STB_XRFInspectionInfo
		   SET LogDateTime = DATEADD(second, (9 * CONVERT(INT, Idx)) + (rand() * 2), @InspectionStartDateTime) 
		 WHERE InspectionNo = @InspectionNo
		
		FETCH NEXT FROM cur INTO @InspectionNo
	END

	CLOSE cur
	DEALLOCATE cur

	-- CreateDateTime : 검사시작일시 + (12 * 시트수)로 일괄 업데이트
	UPDATE STB_XRFInspectionInfo
	   SET CreateDateTime = DATEADD(second, 12 * @SheetCnt, @InspectionStartDateTime)
	 WHERE LotNo = @LotNo

END