-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2015-05-20
-- Description:	스페어파트출고 이력관리IUD
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoSparePartOutHistory_iud]
	@pCompanyCode VARCHAR(20),
	@pWorkCenterCode VARCHAR(20),
	@pOldSparePartIOHistoryNo VARCHAR(20),
	@pSparePartIOHistoryNo VARCHAR(20),
	@pSPWarehouseCode VARCHAR(20),
	@pSparePartCode VARCHAR(20),
	@pSPLocationCode VARCHAR(20),
	@pSparePartIOTypeCode VARCHAR(20),
	@pProcessQty NUMERIC(20,5),
	@pHistoryText NVARCHAR(100),
	@pBasicUnitPrice NUMERIC(15,2),
	@pIUD_FLAG VARCHAR(10),
	
	@pProcessUserID VARCHAR(20),
	@pPrefixString VARCHAR(20),
	@pSerialLen INT,
	@pCurlingGomaUniqueNo VARCHAR(20) = NULL,
	@pLineCode VARCHAR(20) = NULL,
	@pGIDate DATE = NULL,
	@pIssueExecWorkerCode VARCHAR(20) = NULL
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
	DECLARE @ProcessQty NUMERIC(20,5)
	DECLARE @HistoryText NVARCHAR(100)
	DECLARE @BasicUnitPrice NUMERIC(15,2)
	DECLARE @IUD_FLAG VARCHAR(10)
	
	DECLARE @ProcessUserID VARCHAR(20)
	DECLARE @PrefixString VARCHAR(20)
	DECLARE @SerialLen INT
	DECLARE @MaxKeyField VARCHAR(20)
	
	DECLARE @OldSparePartCode VARCHAR(20)
	DECLARE @OldSPLocationCode VARCHAR(20)
	DECLARE @OldProcessQty NUMERIC(20,5)

	DECLARE @CurlingGomaUniqueNo VARCHAR(20)

	Declare @LineCode VARCHAR(20)
	Declare @GIDate DATE
	Declare @IssueExecWorkerCode VARCHAR(20)
	
	
	SET @CompanyCode = @pCompanyCode
	SET @WorkCenterCode = @pWorkCenterCode
	SET @OldSparePartIOHistoryNo = @pOldSparePartIOHistoryNo
	SET @SparePartIOHistoryNo = @pSparePartIOHistoryNo
	SET @SPWarehouseCode = @pSPWarehouseCode
	SET @SparePartCode = @pSparePartCode
	SET @SPLocationCode = @pSPLocationCode
	SET @SparePartIOTypeCode = @pSparePartIOTypeCode
	SET @ProcessQty = ISNULL(@pProcessQty,0)
	SET @HistoryText = @pHistoryText
	SET @BasicUnitPrice = @pBasicUnitPrice
	
	SET @IUD_FLAG = @pIUD_FLAG
	SET @ProcessUserID = @pProcessUserID
	SET @PrefixString = @pPrefixString
	SET @SerialLen = @pSerialLen

	SET @CurlingGomaUniqueNo = @pCurlingGomaUniqueNo
	SET @LineCode = @pLineCode

	SET @GIDate = @pGIDate
	SET @IssueExecWorkerCode = @pIssueExecWorkerCode
	
	SELECT
			@OldSparePartCode = SPIOH.SparePartCode,
			@OldSPLocationCode = SPIOH.SPLocationCode,
			@OldProcessQty = ISNULL(SPIOH.ProcessQty,0)
	FROM
			STB_SparePartIOHistory SPIOH
	WHERE
			SPIOH.SparePartIOHistoryNo = @SparePartIOHistoryNo
			
			
	
			
			
	
	IF @IUD_FLAG = 'INSERT' BEGIN
		PRINT 'INSERT'

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
		    ProcessQty,
		    HistoryText,
		    CreateDateTime,
		    CreateUserID,
			CurlingGomaUniqueNo,
			LineCode,
			GIDate,
			IssueExecWorkerCode
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
		    @ProcessQty,
		    @HistoryText,
		    GETDATE(),
		    @pProcessUserID,
			@CurlingGomaUniqueNo,
			@LineCode,
			@GIDate,
			@IssueExecWorkerCode
		)
		
		
		UPDATE STB_SparePartStockInfo 
		SET
				CurrentStockQty = ISNULL(CurrentStockQty,0) - @ProcessQty
		WHERE
				SPWarehouseCode = @SPWarehouseCode
				AND SPLocationCode = @SPLocationCode
				AND SparePartCode = @SparePartCode
		
		
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
			LineCode =   CASE
		                WHEN @LineCode IS NOT NULL THEN @LineCode
		                ELSE LineCode
		            END,
			GIDate =   CASE
		                WHEN @GIDate IS NOT NULL THEN @GIDate
		                ELSE GIDate
		            END,
			IssueExecWorkerCode =   CASE
		                WHEN @IssueExecWorkerCode IS NOT NULL THEN @IssueExecWorkerCode
		                ELSE IssueExecWorkerCode
		            END,
		    ChangeDateTime = GETDATE(),
		    ChangeUserID = @pProcessUserID
		WHERE
		    SparePartIOHistoryNo = @OldSparePartIOHistoryNo
		    
		    
		    
		IF (@OldSparePartCode = @SparePartCode) AND (@OldSPLocationCode = @SPLocationCode) BEGIN
			UPDATE STB_SparePartStockInfo 
			SET
					CurrentStockQty = ISNULL(CurrentStockQty,0) - (@ProcessQty - @OldProcessQty)
			WHERE
					SPWarehouseCode = @SPWarehouseCode
					AND SPLocationCode = @SPLocationCode
					AND SparePartCode = @SparePartCode
		END
		ELSE BEGIN
			
			UPDATE STB_SparePartStockInfo 
			SET
					CurrentStockQty = ISNULL(CurrentStockQty,0) + @OldProcessQty
			WHERE
					SPWarehouseCode = @SPWarehouseCode
					AND SPLocationCode = @OldSPLocationCode
					AND SparePartCode = @OldSparePartCode
				
			
			UPDATE STB_SparePartStockInfo 
			SET
					CurrentStockQty = ISNULL(CurrentStockQty,0) - @ProcessQty
			WHERE
					SPWarehouseCode = @SPWarehouseCode
					AND SPLocationCode = @SPLocationCode
					AND SparePartCode = @SparePartCode
			
		END
		
		    
	END ELSE 
	IF @IUD_FLAG = 'DELETE' BEGIN
		
        DELETE FROM STB_SparePartIOHistory
		WHERE
		    SparePartIOHistoryNo = @SparePartIOHistoryNo
		   
		   
		UPDATE STB_SparePartStockInfo 
		SET
				CurrentStockQty = ISNULL(CurrentStockQty,0) + @OldProcessQty
		WHERE
				SPWarehouseCode = @SPWarehouseCode
				AND SPLocationCode = @OldSPLocationCode
				AND SparePartCode = @OldSparePartCode
		
	END
	
END

