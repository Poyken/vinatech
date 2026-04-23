-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2015-05-20
-- Description:	스페어파트 입고 이력관리 IUD
-- =============================================
CREATE PROCEDURE [dbo].[usp_VNDoSparePartInHistory_iud]
	@pCompanyCode VARCHAR(20),
	@pWorkCenterCode VARCHAR(20),
	@pOldSparePartIOHistoryNo VARCHAR(20),
	@pSparePartIOHistoryNo VARCHAR(20),
	@pSPWarehouseCode VARCHAR(20),
	@pSparePartCode VARCHAR(20),
	@pSPLocationCode VARCHAR(20),
	@pSparePartIOTypeCode VARCHAR(20),
	@pVendorCode VARCHAR(20),
	@pUnitPrice NUMERIC(20,5),
	@pProcessQty NUMERIC(20,5),
	@pHistoryText NVARCHAR(100),
	@pIUD_FLAG VARCHAR(10),
	
	@pProcessUserID VARCHAR(20),
	@pPrefixString VARCHAR(20),
	@pSerialLen INT,
	@pCurlingGomaUniqueNo VARCHAR(20),
	@pCodeEmp NVARCHAR(50),
	@pAttribute1 NVARCHAR(200),
	@pAttribute2  NVARCHAR(200),
	@pAttribute3 NVARCHAR(200),
	@pAttribute4 NVARCHAR(200),
	@pAttribute5 NVARCHAR(200),
	@pBasicDate DATE,
	@pInvoiceNo NVARCHAR(200)
WITH RECOMPILE
AS
BEGIN

	SET NOCOUNT ON;
	
	DECLARE @CompanyCode VARCHAR(20)
	DECLARE @WorkCenterCode VARCHAR(20)  
	DECLARE @OldSparePartIOHistoryNo VARCHAR(20)  
	DECLARE @SparePartIOHistoryNo VARCHAR(20)  
	DECLARE @SPWarehouseCode VARCHAR(20)  
	DECLARE @SparePartCode VARCHAR(20)  
	DECLARE @SPLocationCode VARCHAR(20)  
	DECLARE @SparePartIOTypeCode VARCHAR(20)  
	DECLARE @VendorCode VARCHAR(20)  
	DECLARE @UnitPrice NUMERIC(20,5)  
	DECLARE @ProcessQty NUMERIC(20,5)  
	DECLARE @HistoryText NVARCHAR(100)  
	DECLARE @IUD_FLAG VARCHAR(10)  
	
	DECLARE @ProcessUserID VARCHAR(20)  
	DECLARE @PrefixString VARCHAR(20)
	DECLARE @SerialLen INT
	DECLARE @MaxKeyField VARCHAR(20)
	
	DECLARE @OldSparePartCode VARCHAR(20)
	DECLARE @OldSPLocationCode VARCHAR(20)
	DECLARE @OldProcessQty NUMERIC(20,5)
	DECLARE @OldWorkCenterCode VARCHAR(20)

	DECLARE @CurlingGomaUniqueNo VARCHAR(20)
	DECLARE	@CodeEmp NVARCHAR(50)
	DECLARE @Attribute1 NVARCHAR(200)
	DECLARE @Attribute2  NVARCHAR(200)
	DECLARE @Attribute3 NVARCHAR(200)
	DECLARE @Attribute4 NVARCHAR(200)
	DECLARE @Attribute5 NVARCHAR(200)
	DECLARE @BasicDate DATE
	DECLARE @InvoiceNo NVARCHAR(200)
	
	SET @CompanyCode = @pCompanyCode
	SET @WorkCenterCode = @pWorkCenterCode
	SET @OldSparePartIOHistoryNo = @pOldSparePartIOHistoryNo
	SET @SparePartIOHistoryNo = @pSparePartIOHistoryNo
	SET @SPWarehouseCode = @pSPWarehouseCode
	SET @SparePartCode = @pSparePartCode
	SET @SPLocationCode = @pSPLocationCode
	SET @SparePartIOTypeCode = @pSparePartIOTypeCode
	SET @VendorCode = @pVendorCode
	SET @UnitPrice = @pUnitPrice
	SET @ProcessQty = ISNULL(@pProcessQty,0)
	SET @HistoryText = @pHistoryText
	
	SET @IUD_FLAG = @pIUD_FLAG
	SET @ProcessUserID = @pProcessUserID
	SET @PrefixString = @pPrefixString
	SET @SerialLen = @pSerialLen

	SET @CurlingGomaUniqueNo = @pCurlingGomaUniqueNo
	SET @CodeEmp = @pCodeEmp
	SET @Attribute1 = @pAttribute1
	SET @Attribute2 = @pAttribute2
	SET @Attribute3 = @pAttribute3
	SET @Attribute4 = @pAttribute4
	SET @Attribute5 = @pAttribute5
	SET @BasicDate = @pBasicDate
	SET @InvoiceNo = @pInvoiceNo
	
	
	SELECT
			@OldSparePartCode = SPIOH.SparePartCode,
			@OldSPLocationCode = SPIOH.SPLocationCode,
			@OldProcessQty = ISNULL(SPIOH.ProcessQty,0),
			@OldWorkCenterCode =SPIOH.WorkCenterCode
	FROM
			STB_VNSparePartIOHistory SPIOH
	WHERE
			SPIOH.SparePartIOHistoryNo = @SparePartIOHistoryNo
			
			
	
	IF @IUD_FLAG = 'INSERT' BEGIN
	
		EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_VNSparePartIOHistory', @SparePartIOHistoryNo OUTPUT
		
		
		INSERT INTO STB_VNSparePartIOHistory
		(
		    SparePartIOHistoryNo,
		    CompanyCode,
		    WorkCenterCode,
		    SPWarehouseCode,
		    SPLocationCode,
		    SparePartIOTypeCode,
		    SparePartCode,
		    VendorCode,
		    UnitPrice,
		    ProcessQty,
		    HistoryText,
		    CreateDateTime,
		    CreateUserID,
			CurlingGomaUniqueNo,
			CodeEmp,
			Attribute1,
			Attribute2 ,
			Attribute3,
			Attribute4 ,
			Attribute5 ,
			BasicDate,
			InvoiceNo
			
		)
		VALUES
		(
		    @SparePartIOHistoryNo,
		    @CompanyCode,
		    @WorkCenterCode,
		    @SPWarehouseCode,
		    @SPLocationCode,
		    @SparePartIOTypeCode,
		    @SparePartCode,
		    @VendorCode,
		    @UnitPrice,
		    @ProcessQty,
		    @HistoryText,
		    GETDATE(),
		    @pProcessUserID,
			@CurlingGomaUniqueNo,
			@CodeEmp,
			@Attribute1,
			@Attribute2,
			@Attribute3,
			@Attribute4,
			@Attribute5,
			@BasicDate,
			@InvoiceNo
		)
		
		IF EXISTS(
					SELECT
							1
					FROM
							STB_VNSparePartStockInfo SPSI
					WHERE
							SPSI.SPWarehouseCode = @SPWarehouseCode
							AND SPSI.SPLocationCode = @SPLocationCode
							AND SPSI.SparePartCode = @SparePartCode
				)BEGIN
			
			UPDATE STB_VNSparePartStockInfo 
			SET
					CurrentStockQty = ISNULL(CurrentStockQty,0) + @ProcessQty
			WHERE
					SPWarehouseCode = @SPWarehouseCode
					AND SPLocationCode = @SPLocationCode
					AND SparePartCode = @SparePartCode
		END
		ELSE BEGIN
			INSERT INTO STB_VNSparePartStockInfo
			(
				SPWarehouseCode,
				SPLocationCode,
				SparePartCode,
				CurrentStockQty
			)
			VALUES
			(
				@SPWarehouseCode,
				@SPLocationCode,
				@SparePartCode,
				@ProcessQty
			)
		END
		-------------------------------------------------------------------------------------- Ha them 07/05/24

				IF EXISTS(
					SELECT
							1
					FROM
							STB_VNSparePartStockInfo_TEST SPSI
							
					WHERE
							SPSI.SPWarehouseCode = @SPWarehouseCode
							AND SPSI.SPLocationCode = @SPLocationCode
							AND SPSI.SparePartCode = @SparePartCode
							AND SPSI.WorkCenterCode = @pWorkCenterCode
						
				)BEGIN
			
			UPDATE STB_VNSparePartStockInfo_TEST
			SET
					CurrentStockQty = ISNULL(CurrentStockQty,0) + @ProcessQty
			WHERE
					SPWarehouseCode = @SPWarehouseCode
					AND SPLocationCode = @SPLocationCode
					AND SparePartCode = @SparePartCode
					AND WorkCenterCode = @pWorkCenterCode
		END
		ELSE BEGIN
			INSERT INTO STB_VNSparePartStockInfo_TEST
			(
				SPWarehouseCode,
				SPLocationCode,
				SparePartCode,
				CurrentStockQty,
				WorkCenterCode
			)
			VALUES
			(
				@SPWarehouseCode,
				@SPLocationCode,
				@SparePartCode,
				@ProcessQty,
				@pWorkCenterCode

			)
			END
		------------------------------------------------------------------------------------------------------------------------------------
		
	END ELSE
	IF @IUD_FLAG = 'UPDATE' BEGIN
					
        UPDATE STB_VNSparePartIOHistory
		SET
		    SparePartIOHistoryNo =   CASE
		                WHEN @SparePartIOHistoryNo IS NOT NULL THEN @SparePartIOHistoryNo
		                ELSE SparePartIOHistoryNo
		            END,
		    CompanyCode =   CASE
		                WHEN @CompanyCode IS NOT NULL THEN @CompanyCode
		                ELSE CompanyCode
		            END,
		    WorkCenterCode =   CASE
		                WHEN @WorkCenterCode IS NOT NULL THEN @WorkCenterCode
		                ELSE WorkCenterCode
		            END,
		    SPWarehouseCode =   CASE
		                WHEN @SPWarehouseCode IS NOT NULL THEN @SPWarehouseCode
		                ELSE SPWarehouseCode
		            END,
		    SPLocationCode =   CASE
		                WHEN @SPLocationCode IS NOT NULL THEN @SPLocationCode
		                ELSE SPLocationCode
		            END,
		    SparePartIOTypeCode =   CASE
		                WHEN @SparePartIOTypeCode IS NOT NULL THEN @SparePartIOTypeCode
		                ELSE SparePartIOTypeCode
		            END,
		    SparePartCode =   CASE
		                WHEN @SparePartCode IS NOT NULL THEN @SparePartCode
		                ELSE SparePartCode
		            END,
		    VendorCode =   CASE
		                WHEN @VendorCode IS NOT NULL THEN @VendorCode
		                ELSE VendorCode
		            END,
		    UnitPrice =   CASE
		                WHEN @UnitPrice IS NOT NULL THEN @UnitPrice
		                ELSE UnitPrice
		            END,
		    ProcessQty =   CASE
		                WHEN @ProcessQty IS NOT NULL THEN @ProcessQty
		                ELSE ProcessQty
		            END,
		    HistoryText =   CASE
		                WHEN @HistoryText IS NOT NULL THEN @HistoryText
		                ELSE HistoryText
		            END,
			CurlingGomaUniqueNo =   CASE
		                WHEN @CurlingGomaUniqueNo IS NOT NULL THEN @CurlingGomaUniqueNo
		                ELSE CurlingGomaUniqueNo
		            END,
			CodeEmp =   CASE
		                WHEN @CodeEmp IS NOT NULL THEN @CodeEmp
		                ELSE CodeEmp
		            END,
			Attribute1 =   CASE
		                WHEN @Attribute1 IS NOT NULL THEN @Attribute1
		                ELSE Attribute1
		            END,
			Attribute2 =   CASE
		                WHEN @Attribute2 IS NOT NULL THEN @Attribute2
		                ELSE Attribute2
		            END,
			Attribute3 =   CASE
		                WHEN @Attribute3 IS NOT NULL THEN @Attribute3
		                ELSE Attribute3
		            END,
			Attribute4 =   CASE
		                WHEN @Attribute4 IS NOT NULL THEN @Attribute4
		                ELSE Attribute4
		            END,
			Attribute5 =   CASE
		                WHEN @Attribute5 IS NOT NULL THEN @Attribute5
		                ELSE Attribute5
		            END,
			BasicDate =   CASE
		                WHEN @BasicDate IS NOT NULL THEN @BasicDate
		                ELSE BasicDate
		            END,
			InvoiceNo = CASE	
						WHEN @InvoiceNo IS NOT NULL THEN @InvoiceNo
						ELSE InvoiceNo
				        END,
		    ChangeDateTime = GETDATE(),
		    ChangeUserID = @pProcessUserID
		WHERE
		    SparePartIOHistoryNo = @OldSparePartIOHistoryNo
		    
		    
		    
		IF (@OldSparePartCode = @SparePartCode) AND (@OldSPLocationCode = @SPLocationCode) BEGIN
			UPDATE STB_VNSparePartStockInfo 
			SET
					CurrentStockQty = ISNULL(CurrentStockQty,0) - (@OldProcessQty - @ProcessQty)
			WHERE
					SPWarehouseCode = @SPWarehouseCode
					AND SPLocationCode = @SPLocationCode
					AND SparePartCode = @SparePartCode
		END
		ELSE BEGIN
			
			UPDATE STB_VNSparePartStockInfo 
			SET
					CurrentStockQty = ISNULL(CurrentStockQty,0) - @OldProcessQty
			WHERE
					SPWarehouseCode = @SPWarehouseCode
					AND SPLocationCode = @OldSPLocationCode
					AND SparePartCode = @OldSparePartCode
				
			
					
			IF EXISTS(
						SELECT
								1
						FROM
								STB_VNSparePartStockInfo SPSI
						WHERE
								SPSI.SPWarehouseCode = @SPWarehouseCode
								AND SPSI.SPLocationCode = @SPLocationCode
								AND SPSI.SparePartCode = @SparePartCode
					)BEGIN
				
				UPDATE STB_VNSparePartStockInfo 
				SET
						CurrentStockQty = ISNULL(CurrentStockQty,0) + @ProcessQty
				WHERE
						SPWarehouseCode = @SPWarehouseCode
						AND SPLocationCode = @SPLocationCode
						AND SparePartCode = @SparePartCode
			END
			ELSE BEGIN
				INSERT INTO STB_VNSparePartStockInfo
				(
					SPWarehouseCode,
					SPLocationCode,
					SparePartCode,
					CurrentStockQty
				)
				VALUES
				(
					@SPWarehouseCode,
					@SPLocationCode,
					@SparePartCode,
					@ProcessQty
				)

					UPDATE STB_VNSparePartStockInfo 
				SET
						CurrentStockQty = ISNULL(CurrentStockQty,0) - @OldProcessQty
				WHERE
						SPWarehouseCode = @SPWarehouseCode
						AND SPLocationCode = @OldSPLocationCode
						AND SparePartCode = @OldSparePartCode


			END
		END
		
		 ----------------------------------------------------------------------------------------------------- Ha them 07/05/24
		 	IF (@OldSparePartCode = @SparePartCode) AND (@OldSPLocationCode = @SPLocationCode) AND (@OldWorkCenterCode =@WorkCenterCode) BEGIN
			UPDATE STB_VNSparePartStockInfo_TEST 
			SET
					CurrentStockQty = ISNULL(CurrentStockQty,0) - (@OldProcessQty - @ProcessQty)
			WHERE
					SPWarehouseCode = @SPWarehouseCode
					AND SPLocationCode = @SPLocationCode
					AND SparePartCode = @SparePartCode
					AND WorkCenterCode = @pWorkCenterCode
		END
		ELSE BEGIN
			
			UPDATE STB_VNSparePartStockInfo_TEST 
			SET
					CurrentStockQty = ISNULL(CurrentStockQty,0) - @OldProcessQty
			WHERE
					SPWarehouseCode = @SPWarehouseCode
					AND SPLocationCode = @OldSPLocationCode
					AND SparePartCode = @OldSparePartCode
					AND WorkCenterCode = @OldWorkCenterCode
			
					
			IF EXISTS(
						SELECT
								1
						FROM
								STB_VNSparePartStockInfo_TEST  SPSI
						WHERE
								SPSI.SPWarehouseCode = @SPWarehouseCode
								AND SPSI.SPLocationCode = @SPLocationCode
								AND SPSI.SparePartCode = @SparePartCode
								AND WorkCenterCode = @WorkCenterCode
					)BEGIN
				
				UPDATE STB_VNSparePartStockInfo_TEST 
				SET
						CurrentStockQty = ISNULL(CurrentStockQty,0) + @ProcessQty
				WHERE
						SPWarehouseCode = @SPWarehouseCode
						AND SPLocationCode = @SPLocationCode
						AND SparePartCode = @SparePartCode
						AND WorkCenterCode = @WorkCenterCode
			END
			ELSE BEGIN
				INSERT INTO STB_VNSparePartStockInfo_TEST 
				(
					SPWarehouseCode,
					SPLocationCode,
					SparePartCode,
					CurrentStockQty,
					WorkCenterCode
				)
				VALUES
				(
					@SPWarehouseCode,
					@SPLocationCode,
					@SparePartCode,
					@ProcessQty,
					@WorkCenterCode
				)

					UPDATE STB_VNSparePartStockInfo_TEST 
				SET
						CurrentStockQty = ISNULL(CurrentStockQty,0) - @OldProcessQty
				WHERE
						SPWarehouseCode = @SPWarehouseCode
						AND SPLocationCode = @OldSPLocationCode
						AND SparePartCode = @OldSparePartCode
						AND WorkCenterCode = @WorkCenterCode


			END
		END
		 
		 ------------------------------------------------------------------------------------------------------------------------------------------------   
	END ELSE 
	IF @IUD_FLAG = 'DELETE' BEGIN
		
        DELETE FROM STB_VNSparePartIOHistory
		WHERE
		    SparePartIOHistoryNo = @SparePartIOHistoryNo
		   
		   
		UPDATE STB_VNSparePartStockInfo 
		SET
				CurrentStockQty = ISNULL(CurrentStockQty,0) - @OldProcessQty
		WHERE
				SPWarehouseCode = @SPWarehouseCode
				AND SPLocationCode = @OldSPLocationCode
				AND SparePartCode = @OldSparePartCode

		-----------------------------------------------------------------  Ha them 07/05/24
		UPDATE STB_VNSparePartStockInfo_TEST 
		SET
				CurrentStockQty = ISNULL(CurrentStockQty,0) - @OldProcessQty
		WHERE
				SPWarehouseCode = @SPWarehouseCode
				AND SPLocationCode = @OldSPLocationCode
				AND SparePartCode = @OldSparePartCode
				AND WorkCenterCode = @pWorkCenterCode

		-----------------------------------------------------------------
	END
	
END

