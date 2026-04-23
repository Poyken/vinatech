CREATE proc [dbo].[usp_DoCreateXRFResultBack]
	@pProcessUserID VARCHAR(20)
   ,@pProcessLanguage VARCHAR(20)
   ,@pLotNo VARCHAR(20)
   ,@pBackStartDateTime VARCHAR(20)
AS
BEGIN
	Declare @LotNo VARCHAR(20) = @pLotNo
	       ,@SheetCnt INT = (SELECT COUNT(*) FROM STB_XRFInspectionInfo WHERE LotNo = @pLotNo)
		   ,@LoopCnt INT = 0
		   ,@InspectionNo BIGINT 
		   ,@InspectionStartDateTime DATETIME = DATEADD(minute, 4, dbo.fnConvertVarcharToDateTime('yyyymmddhhmiss', @pBackStartDateTime))
		   ,@LogDateTime DATETIME
		   ,@Result1 NUMERIC(20,5)

	Declare @BarcodeHeader VARCHAR(8) = LEFT(@LotNo, 8) + '01'

	-- SheetBarcode 조립 및 데이터 입력(전면)
	INSERT INTO STB_XRFInspectionInfo (MachineID, LotNo, Barcode, Idx, RunTime
										   ,Detector, Result1, Result2, Result3, LogDateTime)
			SELECT 'VNMP07001', LotNo, Barcode, ROW_NUMBER() OVER(ORDER BY Barcode DESC), 9000
			      ,'D1', 0.55, 0, 0, GETDATE()
			  FROM STB_XRFInspectionInfo
			 WHERE LotNo = @LotNo
			 ORDER BY Barcode DESC

	-- 런타임 및 결과값 업데이트
	DECLARE cur CURSOR FOR

	SELECT InspectionNo
	  FROM STB_XRFInspectionInfo
	 WHERE LotNo = @LotNo
	   AND CreateDateTime > dbo.fnConvertVarcharToDateTime('yyyymmddhhmiss', @pBackStartDateTime)
	 ORDER BY InspectionNo

	OPEN cur

	FETCH NEXT FROM cur INTO @InspectionNo

	WHILE @@FETCH_STATUS = 0
	BEGIN
		-- Runtime
		UPDATE STB_XRFInspectionInfo
		   SET RunTime = CONVERT(INT, (rand() * 200) + 1800)
		 WHERE InspectionNo = @InspectionNo

		-- Result1
		UPDATE STB_XRFInspectionInfo
		   SET Result1 = Result1 + (rand() * 0.005 + 0.001)
		 WHERE InspectionNo = @InspectionNo

		-- LogDateTime
		UPDATE STB_XRFInspectionInfo
		   SET LogDateTime = DATEADD(second, (18 * CONVERT(INT, Idx)) + (rand() * 2), @InspectionStartDateTime) 
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