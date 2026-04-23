CREATE PROC [dbo].[usp_DoMigrationMaterialQcData]
AS
BEGIN
	Declare @MaterialQcNo VARCHAR(20)
	       ,@CommInspDocNo VARCHAR(20)
		   ,@ProcessLanguage VARCHAR(20) = 'Korean'
		   ,@ProcessUserID VARCHAR(20) = 'eai'
		   ,@CommInspTypeCode VARCHAR(20) = 'ROUTE_QUALITY_VPC'
		   ,@CompanyCode VARCHAR(20)
		   ,@WorkCenterCode VARCHAR(20)
		   ,@PONo VARCHAR(20)
		   ,@ControlNo VARCHAR(20)
		   ,@MaterialCode VARCHAR(20)
		   ,@ProductGroupCode VARCHAR(20)
		   ,@CommInspDocItemNo VARCHAR(20)
		   ,@CommInspItemCode VARCHAR(20)
		   --측정데이터
		   ,@Value1 NUMERIC(20,5)
		   ,@Value2 NUMERIC(20,5)
		   ,@Value3 NUMERIC(20,5)
		   ,@Value4 NUMERIC(20,5)
		   ,@Value5 NUMERIC(20,5)
		   ,@NewBarcode VARCHAR(20)


	SELECT @NewBarcode = NewBarcode  
	  FROM STB_LotChangeMaterialHistory
	 WHERE OldBarcode = @MaterialQcNo


	DECLARE cur CURSOR FOR

	SELECT MaterialQcNo
	  FROM STB_CommInspMigrationTargetInfo

	OPEN cur

	FETCH NEXT FROM cur INTO @MaterialQcNo

	WHILE @@FETCH_STATUS = 0
	BEGIN
		SELECT
			@CommInspDocNo = CIDH.CommInspDocNo,
			@CompanyCode = POI.CompanyCode,
			@WorkCenterCode = POI.WorkCenterCode,
			@PONo = SI.PONo,
			@ControlNo = SI.ControlNo,
			@MaterialCode = SI.MaterialCode,
			@ProductGroupCode = MM.ProductGroupCode
	   FROM STB_SetInfo SI
		LEFT OUTER JOIN STB_ProductionOrderInfo POI		ON POI.PONo = SI.PONo
		LEFT OUTER JOIN STB_CommInspDocHistory CIDH	ON CIDH.CommInspTypeCode = @CommInspTypeCode AND				CIDH.ProdNo = SI.ControlNo
		LEFT OUTER JOIN STB_MaterialMaster MM				ON MM.MaterialCode = SI.MaterialCode
		LEFT OUTER JOIN STB_ModelBasicInfo MBI		ON MM.MaterialCode = MBI.ModelCode
	WHERE 1=1                                                                                                                                                 -- 원본백업
		AND SI.Barcode = @MaterialQcNo OR SI.Barcode = @NewBarcode

	    -- 공용검사 이력 생성
		EXEC usp_DoCreateCommInspDocHistory	@pProcessLanguage = @ProcessLanguage,
											@pProcessUserID = @ProcessUserID,
											@pCommInspTypeCode = @CommInspTypeCode,
											@pCompanyCode = @CompanyCode,
											@pWorkCenterCode = @WorkCenterCode,
											@pRefDoc = @PONo,
											@pProdNo = @ControlNo,
											@pProductGroupCode = @ProductGroupCode,
											@pMaterialCode = @MaterialCode,
											@pLineCode = '',
											@pRouteCode = '',
											@pMachineCode = '',
											@pMoldNumber = '',
											@pCategoryName = '',
											@pCommInspDocNo = @CommInspDocNo OUTPUT

				-- 데이터입력
				DECLARE cur2 CURSOR FOR

				SELECT CommInspDocItemNo, CommInspItemCode
				  FROM STB_CommInspDocItem
				 WHERE CommInspDocNo = @CommInspDocNo

				OPEN cur2

				FETCH NEXT FROM cur2 INTO @CommInspDocItemNo, @CommInspItemCode

				WHILE @@FETCH_STATUS = 0
				BEGIN
					--PQC_V01_07	특성_OCV : RQV_V
					IF @CommInspItemCode = 'RQV_V' BEGIN
						SELECT @Value1 = SUM(CASE WHEN MQSR.MaterialQcSampleNo = 1 THEN TestValue ELSE 0 END)
							  ,@Value2 = SUM(CASE WHEN MQSR.MaterialQcSampleNo = 1 THEN TestValue ELSE 0 END)
							  ,@Value3 = SUM(CASE WHEN MQSR.MaterialQcSampleNo = 1 THEN TestValue ELSE 0 END)
							  ,@Value4 = SUM(CASE WHEN MQSR.MaterialQcSampleNo = 1 THEN TestValue ELSE 0 END)
							  ,@Value5 = SUM(CASE WHEN MQSR.MaterialQcSampleNo = 1 THEN TestValue ELSE 0 END)
						  FROM STB_MaterialQcInfo MQI
						  LEFT OUTER JOIN STB_MaterialQcDetail MQD
							ON MQI.MaterialQcNo = MQD.MaterialQcNo
						  LEFT OUTER JOIN STB_MaterialQcSampleResult MQSR
							ON MQSR.MaterialQcNo = MQI.MaterialQcNo
						   AND MQSR.MaterialQcDetailNo = MQD.MaterialQcDetailNo
						 WHERE MQI.MaterialQcNo = @MaterialQcNo
						   AND QcInspectionItemCode = 'PQC_V01_07'
						   AND MQSR.MaterialQcSampleNo <= 5
					END

					EXEC usp_DoAddCommInspMeasureHistForBarcode_VPC @ProcessUserID , @ProcessLanguage , @CommInspDocNo , @CommInspDocItemNo , NULL
																  , @Value1 , @Value2 , @Value3 , @Value4 , @Value5
																  , NULL , NULL , NULL , NULL , NULL 
																  , NULL , NULL , NULL , NULL , NULL 
																  , NULL , NULL , NULL
					--PQC_V01_01	치수_D : RQV_D
					IF @CommInspItemCode = 'RQV_D' BEGIN
						SELECT @Value1 = SUM(CASE WHEN MQSR.MaterialQcSampleNo = 1 THEN TestValue ELSE 0 END)
							  ,@Value2 = SUM(CASE WHEN MQSR.MaterialQcSampleNo = 1 THEN TestValue ELSE 0 END)
							  ,@Value3 = SUM(CASE WHEN MQSR.MaterialQcSampleNo = 1 THEN TestValue ELSE 0 END)
							  ,@Value4 = SUM(CASE WHEN MQSR.MaterialQcSampleNo = 1 THEN TestValue ELSE 0 END)
							  ,@Value5 = SUM(CASE WHEN MQSR.MaterialQcSampleNo = 1 THEN TestValue ELSE 0 END)
						  FROM STB_MaterialQcInfo MQI
						  LEFT OUTER JOIN STB_MaterialQcDetail MQD
							ON MQI.MaterialQcNo = MQD.MaterialQcNo
						  LEFT OUTER JOIN STB_MaterialQcSampleResult MQSR
							ON MQSR.MaterialQcNo = MQI.MaterialQcNo
						   AND MQSR.MaterialQcDetailNo = MQD.MaterialQcDetailNo
						 WHERE MQI.MaterialQcNo = @MaterialQcNo
						   AND QcInspectionItemCode = 'PQC_V01_01'
						   AND MQSR.MaterialQcSampleNo <= 5
					END

					EXEC usp_DoAddCommInspMeasureHistForBarcode_VPC @ProcessUserID , @ProcessLanguage , @CommInspDocNo , @CommInspDocItemNo , NULL
																  , @Value1 , @Value2 , @Value3 , @Value4 , @Value5
																  , NULL , NULL , NULL , NULL , NULL 
																  , NULL , NULL , NULL , NULL , NULL 
																  , NULL , NULL , NULL
					--PQC_V01_02	치수_M : RQV_M
					IF @CommInspItemCode = 'RQV_M' BEGIN
						SELECT @Value1 = SUM(CASE WHEN MQSR.MaterialQcSampleNo = 1 THEN TestValue ELSE 0 END)
							  ,@Value2 = SUM(CASE WHEN MQSR.MaterialQcSampleNo = 1 THEN TestValue ELSE 0 END)
							  ,@Value3 = SUM(CASE WHEN MQSR.MaterialQcSampleNo = 1 THEN TestValue ELSE 0 END)
							  ,@Value4 = SUM(CASE WHEN MQSR.MaterialQcSampleNo = 1 THEN TestValue ELSE 0 END)
							  ,@Value5 = SUM(CASE WHEN MQSR.MaterialQcSampleNo = 1 THEN TestValue ELSE 0 END)
						  FROM STB_MaterialQcInfo MQI
						  LEFT OUTER JOIN STB_MaterialQcDetail MQD
							ON MQI.MaterialQcNo = MQD.MaterialQcNo
						  LEFT OUTER JOIN STB_MaterialQcSampleResult MQSR
							ON MQSR.MaterialQcNo = MQI.MaterialQcNo
						   AND MQSR.MaterialQcDetailNo = MQD.MaterialQcDetailNo
						 WHERE MQI.MaterialQcNo = @MaterialQcNo
						   AND QcInspectionItemCode = 'PQC_V01_02'
						   AND MQSR.MaterialQcSampleNo <= 5
					END

					EXEC usp_DoAddCommInspMeasureHistForBarcode_VPC @ProcessUserID , @ProcessLanguage , @CommInspDocNo , @CommInspDocItemNo , NULL
																  , @Value1 , @Value2 , @Value3 , @Value4 , @Value5
																  , NULL , NULL , NULL , NULL , NULL 
																  , NULL , NULL , NULL , NULL , NULL 
																  , NULL , NULL , NULL
                    --PQC_V01_03	치수_R : RQV_R
					IF @CommInspItemCode = 'RQV_R' BEGIN
						SELECT @Value1 = SUM(CASE WHEN MQSR.MaterialQcSampleNo = 1 THEN TestValue ELSE 0 END)
							  ,@Value2 = SUM(CASE WHEN MQSR.MaterialQcSampleNo = 1 THEN TestValue ELSE 0 END)
							  ,@Value3 = SUM(CASE WHEN MQSR.MaterialQcSampleNo = 1 THEN TestValue ELSE 0 END)
							  ,@Value4 = SUM(CASE WHEN MQSR.MaterialQcSampleNo = 1 THEN TestValue ELSE 0 END)
							  ,@Value5 = SUM(CASE WHEN MQSR.MaterialQcSampleNo = 1 THEN TestValue ELSE 0 END)
						  FROM STB_MaterialQcInfo MQI
						  LEFT OUTER JOIN STB_MaterialQcDetail MQD
							ON MQI.MaterialQcNo = MQD.MaterialQcNo
						  LEFT OUTER JOIN STB_MaterialQcSampleResult MQSR
							ON MQSR.MaterialQcNo = MQI.MaterialQcNo
						   AND MQSR.MaterialQcDetailNo = MQD.MaterialQcDetailNo
						 WHERE MQI.MaterialQcNo = @MaterialQcNo
						   AND QcInspectionItemCode = 'PQC_V01_03'
						   AND MQSR.MaterialQcSampleNo <= 5
					END

					EXEC usp_DoAddCommInspMeasureHistForBarcode_VPC @ProcessUserID , @ProcessLanguage , @CommInspDocNo , @CommInspDocItemNo , NULL
																  , @Value1 , @Value2 , @Value3 , @Value4 , @Value5
																  , NULL , NULL , NULL , NULL , NULL 
																  , NULL , NULL , NULL , NULL , NULL 
																  , NULL , NULL , NULL
					--PQC_V01_04	치수_B : RQV_B
					IF @CommInspItemCode = 'RQV_B' BEGIN
						SELECT @Value1 = SUM(CASE WHEN MQSR.MaterialQcSampleNo = 1 THEN TestValue ELSE 0 END)
							  ,@Value2 = SUM(CASE WHEN MQSR.MaterialQcSampleNo = 1 THEN TestValue ELSE 0 END)
							  ,@Value3 = SUM(CASE WHEN MQSR.MaterialQcSampleNo = 1 THEN TestValue ELSE 0 END)
							  ,@Value4 = SUM(CASE WHEN MQSR.MaterialQcSampleNo = 1 THEN TestValue ELSE 0 END)
							  ,@Value5 = SUM(CASE WHEN MQSR.MaterialQcSampleNo = 1 THEN TestValue ELSE 0 END)
						  FROM STB_MaterialQcInfo MQI
						  LEFT OUTER JOIN STB_MaterialQcDetail MQD
							ON MQI.MaterialQcNo = MQD.MaterialQcNo
						  LEFT OUTER JOIN STB_MaterialQcSampleResult MQSR
							ON MQSR.MaterialQcNo = MQI.MaterialQcNo
						   AND MQSR.MaterialQcDetailNo = MQD.MaterialQcDetailNo
						 WHERE MQI.MaterialQcNo = @MaterialQcNo
						   AND QcInspectionItemCode = 'PQC_V01_04'
						   AND MQSR.MaterialQcSampleNo <= 5
					END

					EXEC usp_DoAddCommInspMeasureHistForBarcode_VPC @ProcessUserID , @ProcessLanguage , @CommInspDocNo , @CommInspDocItemNo , NULL
																  , @Value1 , @Value2 , @Value3 , @Value4 , @Value5
																  , NULL , NULL , NULL , NULL , NULL 
																  , NULL , NULL , NULL , NULL , NULL 
																  , NULL , NULL , NULL
					--PQC_V01_05	치수_P : RQV_P
					IF @CommInspItemCode = 'RQV_P' BEGIN
						SELECT @Value1 = SUM(CASE WHEN MQSR.MaterialQcSampleNo = 1 THEN TestValue ELSE 0 END)
							  ,@Value2 = SUM(CASE WHEN MQSR.MaterialQcSampleNo = 1 THEN TestValue ELSE 0 END)
							  ,@Value3 = SUM(CASE WHEN MQSR.MaterialQcSampleNo = 1 THEN TestValue ELSE 0 END)
							  ,@Value4 = SUM(CASE WHEN MQSR.MaterialQcSampleNo = 1 THEN TestValue ELSE 0 END)
							  ,@Value5 = SUM(CASE WHEN MQSR.MaterialQcSampleNo = 1 THEN TestValue ELSE 0 END)
						  FROM STB_MaterialQcInfo MQI
						  LEFT OUTER JOIN STB_MaterialQcDetail MQD
							ON MQI.MaterialQcNo = MQD.MaterialQcNo
						  LEFT OUTER JOIN STB_MaterialQcSampleResult MQSR
							ON MQSR.MaterialQcNo = MQI.MaterialQcNo
						   AND MQSR.MaterialQcDetailNo = MQD.MaterialQcDetailNo
						 WHERE MQI.MaterialQcNo = @MaterialQcNo
						   AND QcInspectionItemCode = 'PQC_V01_05'
						   AND MQSR.MaterialQcSampleNo <= 5
					END

					EXEC usp_DoAddCommInspMeasureHistForBarcode_VPC @ProcessUserID , @ProcessLanguage , @CommInspDocNo , @CommInspDocItemNo , NULL
																  , @Value1 , @Value2 , @Value3 , @Value4 , @Value5
																  , NULL , NULL , NULL , NULL , NULL 
																  , NULL , NULL , NULL , NULL , NULL 
																  , NULL , NULL , NULL
	
					FETCH NEXT FROM cur2 INTO @CommInspDocItemNo, @CommInspItemCode
				END

				CLOSE cur2
				DEALLOCATE cur2
	
		FETCH NEXT FROM cur INTO @MaterialQcNo
	END

	CLOSE cur
	DEALLOCATE cur
END