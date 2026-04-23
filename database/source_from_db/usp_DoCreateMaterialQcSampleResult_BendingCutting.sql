-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE usp_DoCreateMaterialQcSampleResult_BendingCutting
				@pMaterialQcNo VARCHAR(20)
			   ,@pMaterialQcDetailNo VARCHAR(20)
			   ,@pSampleQty BIGINT
			   ,@pIsSampleResultClear BIT = 0
AS

BEGIN

	Declare @MaterialQcNo VARCHAR(20) = @pMaterialQcNo
			   ,@MaterialQcDetailNo VARCHAR(20) = @pMaterialQcDetailNo
			   ,@SampleQty BIGINT = @pSampleQty
			   ,@CurrentQty BIGINT = 1
			   ,@IsSampleResultClear BIT = @pIsSampleResultClear

	IF @IsSampleResultClear = 1 

		BEGIN
			DELETE FROM STB_MaterialQcSampleResult_BendingCutting
			        WHERE MaterialQcNo = @MaterialQcNo   AND MaterialQcDetailNo = @MaterialQcDetailNo
		END

   -- While문 실행하여 STB_MaterialQcSampleResult에 Insert
   IF @IsSampleResultClear = 0 BEGIN
		SELECT @CurrentQty = ISNULL(MAX(MaterialQcSampleNo), 0) + 1
		  FROM STB_MaterialQcSampleResult_BendingCutting
		 WHERE MaterialQcNo = @MaterialQcNo   AND MaterialQcDetailNo = @MaterialQcDetailNo
   END

   -- Mr.Manh update 2025-05-16 to create Sample Qty following SI 0.1% Standard by quantity
	DECLARE @WorkCenterCode VARCHAR(20)
	DECLARE @InspectionDocType VARCHAR(20)
	DECLARE @QcInspectionItemCode VARCHAR(20)
	DECLARE @QcQty NUMERIC(20,5) = 0
	

	SELECT  @WorkCenterCode = MQI.WorkCenterCode,
			@InspectionDocType = MQI.InspectionDocType,
			@QcQty = MQI.QcQty,
			@QcInspectionItemCode = MQD.QcInspectionItemCode
	  FROM STB_MaterialQcInfo_BendingCutting MQI
	  LEFT JOIN STB_MaterialQcDetail_BendingCutting MQD ON MQI.MaterialQcNo = MQD.MaterialQcNo
	 WHERE MQI.MaterialQcNo = @MaterialQcNo 
		AND MQD.MaterialQcDetailNo = @MaterialQcDetailNo

	--IF (@WorkCenterCode IN ('VVT_F1', 'VVT_F2') AND @InspectionDocType = 'IQC' AND (@QcInspectionItemCode IN (Select QcInspectionItemCode FROM STB_QcInspectionItem WHERE IsSI01Standard = 1)))
	--	BEGIN
	--		SELECT @SampleQty = CASE 
	--							WHEN (@QcQty > 1 AND @QcQty < 50) THEN 2
	--							WHEN (@QcQty > 51 AND @QcQty < 500) THEN 3
	--							WHEN (@QcQty > 501 AND @QcQty < 35000) THEN 5
	--							WHEN (@QcQty > 35001) THEN 8
	--							ELSE @SampleQty
	--						END 
	--	END
	-- END UPDATE

		WHILE @CurrentQty <= @SampleQty 
	
		BEGIN

			INSERT INTO STB_MaterialQcSampleResult_BendingCutting
			 (
							MaterialQcNo
						   ,MaterialQcDetailNo
						   ,MaterialQcSampleNo
						   ,CreateDateTime
						   ,CreateUserID
			 )
				SELECT @MaterialQcNo
					  ,@MaterialQcDetailNo
					  ,@CurrentQty
					  ,GETDATE()
					  ,'eai'

		SET @CurrentQty = @CurrentQty + 1

	END
END
