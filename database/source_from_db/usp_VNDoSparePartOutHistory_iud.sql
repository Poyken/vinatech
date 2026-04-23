-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2015-05-20
-- Description:	스페어파트출고 이력관리IUD
-- =============================================
CREATE PROCEDURE [dbo].[usp_VNDoSparePartOutHistory_iud]
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
	@pCodeEmp NVARCHAR(50),
	@pAttribute1 NVARCHAR(200),
    @pAttribute2  NVARCHAR(200),
    @pAttribute3 NVARCHAR(200),
    @pAttribute4 NVARCHAR(200),
    @pAttribute5 NVARCHAR(200),
    @pBasicDate Date
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
	DECLARE @OldWorkCenterCode VARCHAR(20)

	DECLARE @CurlingGomaUniqueNo VARCHAR(20)

	Declare @LineCode VARCHAR(20)
	DECLARE @CodeEmp NVARCHAR(50)
	DECLARE @Attribute1 NVARCHAR(200)
	DECLARE @Attribute2  NVARCHAR(200)
	DECLARE @Attribute3 NVARCHAR(200)
	DECLARE @Attribute4 NVARCHAR(200)
	DECLARE @Attribute5 NVARCHAR(200)
	DECLARE @BasicDate Date
	
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

	SET @CodeEmp =@pCodeEmp
	SET @Attribute1 = @pAttribute1
	SET @Attribute2 = @pAttribute2
	SET @Attribute3 = @pAttribute3
	SET @Attribute4 = @pAttribute4
	SET @pAttribute5 = @pAttribute5
	SET @BasicDate =  @pBasicDate
	
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
		PRINT 'INSERT'

		EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_VNSparePartIOHistory', @SparePartIOHistoryNo OUTPUT
		
		
		if(@pCompanyCode='VVT') begin            --Add by Mr.Tung on 2022-10-17 for Accounting Report
				set @SparePartIOHistoryNo = substring(@SparePartIOHistoryNo,3,len(@SparePartIOHistoryNo))
				set @SparePartIOHistoryNo = substring(@SparePartIOHistoryNo,1,6) + 
										substring(@SparePartIOHistoryNo,len(@SparePartIOHistoryNo)-2,3);
		end
		
		
		INSERT INTO STB_VNSparePartIOHistory
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
			CodeEmp,
			Attribute1,
			Attribute2,
			Attribute3,
			Attribute4,
			Attribute5,
			BasicDate
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
			@CodeEmp,
			@Attribute1,
			@Attribute2,
			@Attribute3,
			@Attribute4,
			@Attribute5,
			@BasicDate
		)
		
		
		UPDATE STB_VNSparePartStockInfo 
		SET
				CurrentStockQty = ISNULL(CurrentStockQty,0) - @ProcessQty
		WHERE
				SPWarehouseCode = @SPWarehouseCode
				AND SPLocationCode = @SPLocationCode
				AND SparePartCode = @SparePartCode
		
		-------------------------------------------------------------------------------------- Ha them 07/05/24

			UPDATE STB_VNSparePartStockInfo_TEST 
		SET
				CurrentStockQty = ISNULL(CurrentStockQty,0) - @ProcessQty
		WHERE
				SPWarehouseCode = @SPWarehouseCode
				AND SPLocationCode = @SPLocationCode
				AND SparePartCode = @SparePartCode
				AND WorkCenterCode = @pWorkCenterCode
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
		    ChangeDateTime = GETDATE(),
		    ChangeUserID = @pProcessUserID
		WHERE
		    SparePartIOHistoryNo = @OldSparePartIOHistoryNo
		    
		    
		    
		IF (@OldSparePartCode = @SparePartCode) AND (@OldSPLocationCode = @SPLocationCode) BEGIN
			UPDATE STB_VNSparePartStockInfo 
			SET
					CurrentStockQty = ISNULL(CurrentStockQty,0) - (@ProcessQty - @OldProcessQty)
			WHERE
					SPWarehouseCode = @SPWarehouseCode
					AND SPLocationCode = @SPLocationCode
					AND SparePartCode = @SparePartCode
		END
		ELSE BEGIN
			
			UPDATE STB_VNSparePartStockInfo 
			SET
					CurrentStockQty = ISNULL(CurrentStockQty,0) + @OldProcessQty
			WHERE
					SPWarehouseCode = @SPWarehouseCode
					AND SPLocationCode = @OldSPLocationCode
					AND SparePartCode = @OldSparePartCode
				
			
			UPDATE STB_VNSparePartStockInfo 
			SET
					CurrentStockQty = ISNULL(CurrentStockQty,0) - @ProcessQty
			WHERE
					SPWarehouseCode = @SPWarehouseCode
					AND SPLocationCode = @SPLocationCode
					AND SparePartCode = @SparePartCode
			
		END

		-------------------------------------------------------------------------------------- Ha them 07/05/24
		 	IF (@OldSparePartCode = @SparePartCode) AND (@OldSPLocationCode = @SPLocationCode) AND (@OldWorkCenterCode =@WorkCenterCode)BEGIN
			UPDATE STB_VNSparePartStockInfo_TEST 
			SET
					CurrentStockQty = ISNULL(CurrentStockQty,0) - (@ProcessQty - @OldProcessQty)
			WHERE
					SPWarehouseCode = @SPWarehouseCode
					AND SPLocationCode = @SPLocationCode
					AND SparePartCode = @SparePartCode
					AND WorkCenterCode = @pWorkCenterCode
		END
		ELSE BEGIN
			
			UPDATE STB_VNSparePartStockInfo_TEST  
			SET
					CurrentStockQty = ISNULL(CurrentStockQty,0) + @OldProcessQty
			WHERE
					SPWarehouseCode = @SPWarehouseCode
					AND SPLocationCode = @OldSPLocationCode
					AND SparePartCode = @OldSparePartCode
					AND WorkCenterCode = @OldWorkCenterCode
				
			
			UPDATE STB_VNSparePartStockInfo_TEST 
			SET
					CurrentStockQty = ISNULL(CurrentStockQty,0) - @ProcessQty
			WHERE
					SPWarehouseCode = @SPWarehouseCode
					AND SPLocationCode = @SPLocationCode
					AND SparePartCode = @SparePartCode
					AND WorkCenterCode = @WorkCenterCode
			
		END
		 ------------------------------------------------------------------------------------------------------------------------------------------------   
		
		    
	END ELSE 
	IF @IUD_FLAG = 'DELETE' BEGIN
		
        DELETE FROM STB_VNSparePartIOHistory
		WHERE
		    SparePartIOHistoryNo = @SparePartIOHistoryNo
		   
		   
		UPDATE STB_VNSparePartStockInfo 
		SET
				CurrentStockQty = ISNULL(CurrentStockQty,0) + @OldProcessQty
		WHERE
				SPWarehouseCode = @SPWarehouseCode
				AND SPLocationCode = @OldSPLocationCode
				AND SparePartCode = @OldSparePartCode
		-----------------------------------------------------------------  Ha them 07/05/24

		UPDATE STB_VNSparePartStockInfo_TEST  
		SET
				CurrentStockQty = ISNULL(CurrentStockQty,0) + @OldProcessQty
		WHERE
				SPWarehouseCode = @SPWarehouseCode
				AND SPLocationCode = @OldSPLocationCode
				AND SparePartCode = @OldSparePartCode
				AND WorkCenterCode = @pWorkCenterCode
		-----------------------------------------------------------------
	END
	
END

