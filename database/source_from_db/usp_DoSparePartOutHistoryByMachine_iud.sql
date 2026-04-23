-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2015-05-20
-- Description:	스페어파트출고 이력관리 및 스페어파트 교체 이력관리 Process
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoSparePartOutHistoryByMachine_iud]
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
	@pMachineCode VARCHAR(20),
	@pBasicUnitPrice NUMERIC(15,2),
	@pIUD_FLAG VARCHAR(10),
	
	@pProcessUserID VARCHAR(20),
	@pPrefixString VARCHAR(20),
	@pSerialLen INT,
	@pCurlingGomaUniqueNo VARCHAR(20),
	@pGIDate DATE,
	@pIssueExecWorkerCode VARCHAR(20)
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
	DECLARE @MachineCode VARCHAR(20)
	DECLARE @BasicUnitPrice NUMERIC(15,2)
	DECLARE @IUD_FLAG VARCHAR(10)
	
	DECLARE @ProcessUserID VARCHAR(20)
	DECLARE @PrefixString VARCHAR(20)
	DECLARE @SerialLen INT
	DECLARE @MaxKeyField VARCHAR(20)
	
	DECLARE @OldSparePartCode VARCHAR(20)
	DECLARE @OldSPLocationCode VARCHAR(20)
	DECLARE @OldProcessQty NUMERIC(20,5)
	
	DECLARE @SparePartChangeHistoryNo VARCHAR(20)
	
	DECLARE @SpareChangeDate DATE

	DECLARE @CurlingGomaUniqueNo VARCHAR(20)

	DECLARE @GIDate DATE 
	DECLARE @IssueExecWorkerCode VARCHAR(20)
	
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
	SET @MachineCode = @pMachineCode
	SET @BasicUnitPrice = @pBasicUnitPrice
	
	SET @IUD_FLAG = @pIUD_FLAG
	SET @ProcessUserID = @pProcessUserID
	SET @PrefixString = @pPrefixString
	SET @SerialLen = @pSerialLen
	
	SET @CurlingGomaUniqueNo = @pCurlingGomaUniqueNo

	SET @GIDate = @pGIDate
	SET @IssueExecWorkerCode = @pIssueExecWorkerCode
	
	
	
	SELECT
			@OldSparePartCode = SPIOH.SparePartCode,
			@OldSPLocationCode = SPIOH.SPLocationCode,
			@OldProcessQty = ISNULL(SPIOH.ProcessQty,0),
			@SparePartChangeHistoryNo = SPCH.SparePartChangeHistoryNo
	FROM
			STB_SparePartIOHistory SPIOH
			LEFT OUTER JOIN STB_SparePartChangeHistory SPCH
				ON SPIOH.SparePartIOHistoryNo = SPCH.SparePartIOHistoryNo
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
		    @VendorCode,
		    @UnitPrice,
		    @ProcessQty,
		    @HistoryText,
		    GETDATE(),
		    @pProcessUserID,
			@CurlingGomaUniqueNo,
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
		
		
		
		EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_SparePartChangeHistory',
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
		
		SELECT
				@MaxKeyField = MAX(SparePartChangeHistoryNo)
		FROM
				STB_SparePartChangeHistory 
		WHERE
				SparePartChangeHistoryNo LIKE @PrefixString + '%'
									
		IF @MaxKeyField IS NULL BEGIN
		    SET @SparePartChangeHistoryNo = @PrefixString + RIGHT(REPLICATE('0',@SerialLen) + '1', @SerialLen)
		END ELSE BEGIN
		    SET @SparePartChangeHistoryNo = @PrefixString + RIGHT(REPLICATE('0',@SerialLen) + CONVERT(VARCHAR, CONVERT(BIGINT, RIGHT(@MaxKeyField, LEN(@MaxKeyField) - LEN(@PrefixString))) + 1), @SerialLen)
		END
		
		
		--스페어파트교체이력 등록
		INSERT INTO STB_SparePartChangeHistory
		(
		    SparePartChangeHistoryNo,
		    CompanyCode,
		    WorkCenterCode,
		    MachineCode,
		    SparePartCode,
		    ChangeQty,
		    BasicUnitPrice,
		    SpareChangeDate,
		    SpareChangeDateTime,
		    IsMachineRepair,
		    SparePartIOHistoryNo,
		    CreateDateTime,
		    CreateUserID
		)
		VALUES
		(
		    @SparePartChangeHistoryNo,
		    @CompanyCode,
		    @WorkCenterCode,
		    @MachineCode,
		    @SparePartCode,
		    @ProcessQty,
		    @BasicUnitPrice,
		    GETDATE(),
		    GETDATE(),
		    0,
		    @SparePartIOHistoryNo,
		    GETDATE(),
		    @pProcessUserID
		)
		
		
		UPDATE STB_MachineSparePartInfo
		SET
				LastChangeDate = GETDATE()
		WHERE
				MachineCode = @MachineCode
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
					
			
			
			UPDATE STB_SparePartChangeHistory
			SET
					MachineCode = @MachineCode,
					SparePartCode = @SparePartCode,
					ChangeQty = @ProcessQty,
					BasicUnitPrice = @BasicUnitPrice,
					SpareChangeDate = GETDATE(),
					SpareChangeDateTime = GETDATE(),
					IsMachineRepair = 0,
					SparePartIOHistoryNo = @SparePartIOHistoryNo
			WHERE
					SparePartChangeHistoryNo = @SparePartChangeHistoryNo
					
			
		END
		
		
		IF @OldSparePartCode <> @SparePartCode BEGIN
			
			SELECT
					@SpareChangeDate = SPCH.SpareChangeDate
			FROM
					STB_SparePartChangeHistory SPCH
			WHERE
					SPCH.MachineCode = @MachineCode
					AND SPCH.SparePartCode = @OldSparePartCode
			
			UPDATE STB_MachineSparePartInfo
			SET
					LastChangeDate = @SpareChangeDate
			WHERE
					MachineCode = @MachineCode
					AND SparePartCode = @OldSparePartCode
		END
		
		UPDATE STB_MachineSparePartInfo
		SET
				LastChangeDate = GETDATE()
		WHERE
				MachineCode = @MachineCode
				AND SparePartCode = @SparePartCode
		
		    
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
		
		DELETE FROM STB_SparePartChangeHistory
		WHERE
				 SparePartChangeHistoryNo = @SparePartChangeHistoryNo
				 
			
			
		SELECT
				@SpareChangeDate = SPCH.SpareChangeDate
		FROM
				STB_SparePartChangeHistory SPCH
		WHERE
				SPCH.MachineCode = @MachineCode
				AND SPCH.SparePartCode = @OldSparePartCode
		
		UPDATE STB_MachineSparePartInfo
		SET
				LastChangeDate = @SpareChangeDate
		WHERE
				MachineCode = @MachineCode
				AND SparePartCode = @OldSparePartCode
	END
	
END

