-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2015-05-20
-- Description:	스페어파트 입고 이력관리 IUD
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoSparePartInHistory_iud]
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
	@pGRDate DATE
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

	DECLARE @CurlingGomaUniqueNo VARCHAR(20)

	DECLARE @GRDate DATE = @pGRDate
	
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
	
	
	
	SELECT
			@OldSparePartCode = SPIOH.SparePartCode,
			@OldSPLocationCode = SPIOH.SPLocationCode,
			@OldProcessQty = ISNULL(SPIOH.ProcessQty,0)
	FROM
			STB_SparePartIOHistory SPIOH
	WHERE
			SPIOH.SparePartIOHistoryNo = @SparePartIOHistoryNo
			
			
	
	IF @IUD_FLAG = 'INSERT' BEGIN
	
		EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_SparePartIOHistory', @SparePartIOHistoryNo OUTPUT
		
		
		INSERT INTO STB_SparePartIOHistory
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
			GRDate
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
			@GRDate
		)
		
		IF EXISTS(
					SELECT
							1
					FROM
							STB_SparePartStockInfo SPSI
					WHERE
							SPSI.SPWarehouseCode = @SPWarehouseCode
							AND SPSI.SPLocationCode = @SPLocationCode
							AND SPSI.SparePartCode = @SparePartCode
				)BEGIN
			
			UPDATE STB_SparePartStockInfo 
			SET
					CurrentStockQty = ISNULL(CurrentStockQty,0) + @ProcessQty
			WHERE
					SPWarehouseCode = @SPWarehouseCode
					AND SPLocationCode = @SPLocationCode
					AND SparePartCode = @SparePartCode
		END
		ELSE BEGIN
			INSERT INTO STB_SparePartStockInfo
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
		
		
	END ELSE
	IF @IUD_FLAG = 'UPDATE' BEGIN
					
        UPDATE STB_SparePartIOHistory
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
		    ChangeDateTime = GETDATE(),
		    ChangeUserID = @pProcessUserID,
			GRDate = CASE WHEN @GRDate IS NOT NULL THEN @GRDate ELSE GRDate END
		WHERE
		    SparePartIOHistoryNo = @OldSparePartIOHistoryNo
		    
		    
		    
		IF (@OldSparePartCode = @SparePartCode) AND (@OldSPLocationCode = @SPLocationCode) BEGIN
			UPDATE STB_SparePartStockInfo 
			SET
					CurrentStockQty = ISNULL(CurrentStockQty,0) - (@OldProcessQty - @ProcessQty)
			WHERE
					SPWarehouseCode = @SPWarehouseCode
					AND SPLocationCode = @SPLocationCode
					AND SparePartCode = @SparePartCode
		END
		ELSE BEGIN
			
			UPDATE STB_SparePartStockInfo 
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
								STB_SparePartStockInfo SPSI
						WHERE
								SPSI.SPWarehouseCode = @SPWarehouseCode
								AND SPSI.SPLocationCode = @SPLocationCode
								AND SPSI.SparePartCode = @SparePartCode
					)BEGIN
				
				UPDATE STB_SparePartStockInfo 
				SET
						CurrentStockQty = ISNULL(CurrentStockQty,0) + @ProcessQty
				WHERE
						SPWarehouseCode = @SPWarehouseCode
						AND SPLocationCode = @SPLocationCode
						AND SparePartCode = @SparePartCode
			END
			ELSE BEGIN
				INSERT INTO STB_SparePartStockInfo
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
		END
		
		    
	END ELSE 
	IF @IUD_FLAG = 'DELETE' BEGIN
		
        DELETE FROM STB_SparePartIOHistory
		WHERE
		    SparePartIOHistoryNo = @SparePartIOHistoryNo
		   
		   
		UPDATE STB_SparePartStockInfo 
		SET
				CurrentStockQty = ISNULL(CurrentStockQty,0) - @OldProcessQty
		WHERE
				SPWarehouseCode = @SPWarehouseCode
				AND SPLocationCode = @OldSPLocationCode
				AND SparePartCode = @OldSparePartCode
	END
	
END

