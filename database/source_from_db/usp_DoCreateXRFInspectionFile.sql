-- Font Recipe Name : 158-100
-- Back Recipe Name : 158-137
CREATE proc usp_DoCreateXRFInspectionFile
	@pLotNo VARCHAR(20)
   ,@pIsFront BIT = 1
AS
BEGIN
	Declare @LotNo VARCHAR(20) = @pLotNo
	Declare @IsFront BIT = @pIsFront
	Declare @SheetCnt INT
	Declare @LotStartDateTime DATETIME
	Declare @LotEndDateTime DATETIME

	Declare @TargetData TABLE (
		D1 VARCHAR(50)
	   ,D2 VARCHAR(50)
	   ,D3 VARCHAR(50)
	   ,D4 VARCHAR(50)
	   ,D5 VARCHAR(50)
	   ,D6 VARCHAR(50)
	   ,D7 VARCHAR(50)
	   ,D8 VARCHAR(50)
	);

	Declare @ResultData TABLE (
		D1 VARCHAR(50)
	   ,D2 VARCHAR(50)
	   ,D3 VARCHAR(50)
	   ,D4 VARCHAR(50)
	   ,D5 VARCHAR(50)
	   ,D6 VARCHAR(50)
	   ,D7 VARCHAR(50)
	   ,D8 VARCHAR(50)
	);

	SELECT @SheetCnt = COUNT(*) / 2 
	  FROM STB_XRFInspectionInfo
	 WHERE LotNo = @LotNo

	-- Lot Start Time & End Time
	IF @IsFront = CONVERT(BIT, 1) BEGIN
		SELECT @LotStartDateTime = MIN(A.LogDateTime)
		      ,@LotEndDateTime = MAX(A.LogDateTime)
		  FROM (
				SELECT TOP (@SheetCnt)
					   *
				  FROM STB_XRFInspectionInfo
				 WHERE LotNo = @LotNo
				 ORDER BY LogDateTime ASC
			  ) A

		 INSERT INTO @TargetData
			SELECT TOP (@SheetCnt)
				   CONVERT(VARCHAR(30), LogDateTime, 121)
				 , CONVERT(VARCHAR(10), CONVERT(INT, RunTime))
				 , Detector
				 , ''''+Barcode
				 , CONVERT(VARCHAR(10), CONVERT(INT, Idx))
				 , CONVERT(VARCHAR(20), Result1)
				 , CONVERT(VARCHAR(20), Result2)
				 , CONVERT(VARCHAR(20), Result3)
			  FROM STB_XRFInspectionInfo
			 WHERE LotNo = @LotNo
			 ORDER BY InspectionNo

		 INSERT INTO @ResultData
		 SELECT 'Lot ID : ' + @LotNo AS D1, NULL AS D2, NULL AS D3, NULL AS D4, NULL AS D5, NULL AS D6, NULL AS D7, NULL AS D8
		 UNION ALL
		 SELECT 'Lot Start Time : ' + CONVERT(VARCHAR(30), @LotStartDateTime, 121), NULL, NULL, NULL, NULL, NULL, NULL, NULL
		 UNION ALL
		 SELECT 'Lot End Time : ' + CONVERT(VARCHAR(30), @LotEndDateTime, 121), NULL, NULL, NULL, NULL, NULL, NULL, NULL
		 UNION ALL
		 SELECT 'Lot End : OK', NULL, NULL, NULL, NULL, NULL, NULL, NULL
		 UNION ALL
		 SELECT 'Recipe Name : 158-137', NULL, NULL, NULL, NULL, NULL, NULL, NULL
		 UNION ALL
		 SELECT 'kV : 40', NULL, NULL, NULL, NULL, NULL, NULL, NULL
		 UNION ALL
		 SELECT 'mA : 1', NULL, NULL, NULL, NULL, NULL, NULL, NULL
		 UNION ALL
		 SELECT 'Chip X Size : 158.4', NULL, NULL, NULL, NULL, NULL, NULL, NULL
		 UNION ALL
		 SELECT 'Chip Y Size : 137', NULL, NULL, NULL, NULL, NULL, NULL, NULL
		 UNION ALL
		 SELECT 'Chip I Size : 18', NULL, NULL, NULL, NULL, NULL, NULL, NULL
		 UNION ALL
		 SELECT 'Element #01 : Pt', NULL, NULL, NULL, NULL, NULL, NULL, NULL
		 UNION ALL
		 SELECT 'Element #01 Spec Low : 0.35', NULL, NULL, NULL, NULL, NULL, NULL, NULL
		 UNION ALL
		 SELECT 'Element #01 Spec High : 0.5', NULL, NULL, NULL, NULL, NULL, NULL, NULL
		 UNION ALL
		 SELECT 'Element #02 : ', NULL, NULL, NULL, NULL, NULL, NULL, NULL
		 UNION ALL
		 SELECT 'Element #02 Spec Low : 0', NULL, NULL, NULL, NULL, NULL, NULL, NULL
		 UNION ALL
		 SELECT 'Element #02 Spec High : 0', NULL, NULL, NULL, NULL, NULL, NULL, NULL
		 UNION ALL
		 SELECT 'Element #03 : ', NULL, NULL, NULL, NULL, NULL, NULL, NULL
		 UNION ALL
		 SELECT 'Element #03 Spec Low : 0', NULL, NULL, NULL, NULL, NULL, NULL, NULL
		 UNION ALL
		 SELECT 'Element #03 Spec High : 0', NULL, NULL, NULL, NULL, NULL, NULL, NULL
		 UNION ALL
		 SELECT NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
		 UNION ALL
		 SELECT '[Log Time]','[Run Time]','[Detector No]','[BarCode]','[Index]','[E1 Thick]','[E2 Thick]','[E3 Thick]'
		 UNION ALL
		 -- 실데이터
		 SELECT TOP (@SheetCnt)
	           D1
			  ,D2
			  ,D3
			  ,D4
			  ,D5
			  ,D6
			  ,D7
			  ,D8
		  FROM @TargetData
	END ELSE BEGIN
		SELECT @LotStartDateTime = MIN(A.LogDateTime)
		      ,@LotEndDateTime = MAX(A.LogDateTime)
		  FROM (SELECT TOP 10000 *
				  FROM STB_XRFInspectionInfo
				 WHERE LotNo = @LotNo
				   AND InspectionNo NOT IN (SELECT TOP (@SheetCnt) InspectionNo 
												  FROM STB_XRFInspectionInfo 
												 WHERE LotNo = @LotNo 
												 ORDER BY InspectionNo)
				 ORDER BY InspectionNo ASC
			) A

		INSERT INTO @TargetData
			SELECT CONVERT(VARCHAR(30), LogDateTime, 121)
				 , CONVERT(VARCHAR(10), CONVERT(INT, RunTime))
				 , Detector
				 , ''''+Barcode
				 , CONVERT(VARCHAR(10), CONVERT(INT, Idx))
				 , CONVERT(VARCHAR(20), Result1)
				 , CONVERT(VARCHAR(20), Result2)
				 , CONVERT(VARCHAR(20), Result3)
			  FROM STB_XRFInspectionInfo
			 WHERE LotNo = @LotNo
			   AND InspectionNo NOT IN (SELECT TOP (@SheetCnt) InspectionNo 
			                              FROM STB_XRFInspectionInfo 
										 WHERE LotNo = @LotNo 
										 ORDER BY InspectionNo)
			 ORDER BY InspectionNo

		 INSERT INTO @ResultData
		 SELECT 'Lot ID : ' + @LotNo AS D1, NULL AS D2, NULL AS D3, NULL AS D4, NULL AS D5, NULL AS D6, NULL AS D7, NULL AS D8
		 UNION ALL
		 SELECT 'Lot Start Time : ' + CONVERT(VARCHAR(30), @LotStartDateTime, 121), NULL, NULL, NULL, NULL, NULL, NULL, NULL
		 UNION ALL
		 SELECT 'Lot End Time : ' + CONVERT(VARCHAR(30), @LotEndDateTime, 121), NULL, NULL, NULL, NULL, NULL, NULL, NULL
		 UNION ALL
		 SELECT 'Lot End : OK', NULL, NULL, NULL, NULL, NULL, NULL, NULL
		 UNION ALL
		 SELECT 'Recipe Name : 158-100', NULL, NULL, NULL, NULL, NULL, NULL, NULL
		 UNION ALL
		 SELECT 'kV : 40', NULL, NULL, NULL, NULL, NULL, NULL, NULL
		 UNION ALL
		 SELECT 'mA : 1', NULL, NULL, NULL, NULL, NULL, NULL, NULL
		 UNION ALL
		 SELECT 'Chip X Size : 158.4', NULL, NULL, NULL, NULL, NULL, NULL, NULL
		 UNION ALL
		 SELECT 'Chip Y Size : 137', NULL, NULL, NULL, NULL, NULL, NULL, NULL
		 UNION ALL
		 SELECT 'Chip I Size : 18', NULL, NULL, NULL, NULL, NULL, NULL, NULL
		 UNION ALL
		 SELECT 'Element #01 : Pt', NULL, NULL, NULL, NULL, NULL, NULL, NULL
		 UNION ALL
		 SELECT 'Element #01 Spec Low : 0.5', NULL, NULL, NULL, NULL, NULL, NULL, NULL
		 UNION ALL
		 SELECT 'Element #01 Spec High : 0.7', NULL, NULL, NULL, NULL, NULL, NULL, NULL
		 UNION ALL
		 SELECT 'Element #02 : ', NULL, NULL, NULL, NULL, NULL, NULL, NULL
		 UNION ALL
		 SELECT 'Element #02 Spec Low : 0', NULL, NULL, NULL, NULL, NULL, NULL, NULL
		 UNION ALL
		 SELECT 'Element #02 Spec High : 0', NULL, NULL, NULL, NULL, NULL, NULL, NULL
		 UNION ALL
		 SELECT 'Element #03 : ', NULL, NULL, NULL, NULL, NULL, NULL, NULL
		 UNION ALL
		 SELECT 'Element #03 Spec Low : 0', NULL, NULL, NULL, NULL, NULL, NULL, NULL
		 UNION ALL
		 SELECT 'Element #03 Spec High : 0', NULL, NULL, NULL, NULL, NULL, NULL, NULL
		 UNION ALL
		 SELECT NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
		 UNION ALL
		 SELECT '[Log Time]','[Run Time]','[Detector No]','[BarCode]','[Index]','[E1 Thick]','[E2 Thick]','[E3 Thick]'
		 UNION ALL
		 -- 실데이터
		 SELECT TOP (@SheetCnt)
	           D1
			  ,D2
			  ,D3
			  ,D4
			  ,D5
			  ,D6
			  ,D7
			  ,D8
		  FROM @TargetData
	END

	SELECT *
	  FROM @ResultData
END