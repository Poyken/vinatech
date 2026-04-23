

CREATE PROCEDURE [dbo].[usp_StationeryInOutHistory_iud]
	 @pOldSIOHistoryNo VARCHAR(20),
	 @pSIOHistoryNo VARCHAR(20),
	 @pCompanyCode VARCHAR(20),
	 @pWorkCenterCode VARCHAR(20),
	 @pSWarehouse VARCHAR(20),
	 @pSIOTypeCode VARCHAR(50),
	 @pStationeyCode VARCHAR(50),
	 @pVendorCode VARCHAR(50),
	 @pUnitPrice NUMERIC(20,5),
	 @pQuanlity NUMERIC(20,5),
	 @pDept NVARCHAR(50),
	 @pPurpose NVARCHAR(500),
	 @pDescription NVARCHAR(500),

	 @pIUD_FLAG VARCHAR(10),
	 @pProcessUserID VARCHAR(20),
	 @pPrefixString VARCHAR(20),
	 @pSerialLen INT,

	 @pLineCode NVARCHAR(50),
	 @pEmpNo NVARCHAR(20),
	 @pAttribute1 NVARCHAR(50),
	 @pAttribute2  NVARCHAR(50),
	 @pAttribute3 NVARCHAR(50),
	 @pAttribute4 NVARCHAR(50),
	 @pAttribute5 NVARCHAR(50),
	 @pBasicDate Date,
	 @pInvoiceNo NVARCHAR(50),
	 @pToSWarehouse NVARCHAR(50),
	 @pIsConfirm BIT,
	 @pDateConfirm DATE
WITH RECOMPILE
AS
BEGIN

	SET NOCOUNT ON;
	
	DECLARE @OldSIOHistoryNo VARCHAR(20)
	DECLARE @SIOHistoryNo VARCHAR(20)
	DECLARE @CompanyCode VARCHAR(20)
	DECLARE @WorkCenterCode VARCHAR(20)
	DECLARE @SWarehouse VARCHAR(20)
	DECLARE @SIOTypeCode VARCHAR(50)
	DECLARE @StationeyCode VARCHAR(50)
	DECLARE @VendorCode VARCHAR(50)
	DECLARE @UnitPrice NUMERIC(20,5)
	DECLARE @Quanlity NUMERIC(20,5)
	DECLARE @Dept NVARCHAR(50)
	DECLARE @Purpose NVARCHAR(500)
	DECLARE @Description NVARCHAR(500)

	DECLARE @IUD_FLAG VARCHAR(10)
	DECLARE @ProcessUserID VARCHAR(20)
	DECLARE @PrefixString VARCHAR(20)
	DECLARE @SerialLen INT
	DECLARE @MaxKeyField VARCHAR(20)

	DECLARE @LineCode VARCHAR(50)
	DECLARE @EmpNo NVARCHAR(20)
	DECLARE @Attribute1 NVARCHAR(50)
	DECLARE @Attribute2  NVARCHAR(50)
	DECLARE @Attribute3 NVARCHAR(50)
	DECLARE @Attribute4 NVARCHAR(50)
	DECLARE @Attribute5 NVARCHAR(50)
	DECLARE @BasicDate Date
	DECLARE @InvoiceNo NVARCHAR(50)
	DECLARE @ToSWarehouse NVARCHAR(50)
	DECLARE @IsConfirm BIT
	DECLARE @DateConfirm DATE
	
	SET @CompanyCode = @pCompanyCode
	SET @WorkCenterCode = @pWorkCenterCode
	SET @OldSIOHistoryNo = @pOldSIOHistoryNo
	SET @SIOHistoryNo = @pSIOHistoryNo
	SET @SWarehouse = @pSWarehouse
	SET @SIOTypeCode = @pSIOTypeCode
	SET @StationeyCode = @pStationeyCode
	SET @VendorCode = @pVendorCode
	SET @UnitPrice = @pUnitPrice
	SET @Quanlity = ISNULL(@pQuanlity,0)
	SET @Dept = @pDept
	SET @Purpose = @pPurpose
	SET @Description = @pDescription
	
	SET @IUD_FLAG = @pIUD_FLAG
	SET @ProcessUserID = @pProcessUserID
	SET @PrefixString = @pPrefixString
	SET @SerialLen = @pSerialLen

	SET @LineCode = @pLineCode
	SET @EmpNo = @pEmpNo
	SET @Attribute1 = @pAttribute1
	SET @Attribute2 = @pAttribute2
	SET @Attribute3 = @pAttribute3
	SET @Attribute4 = @pAttribute4
	SET @Attribute5 = @pAttribute5
	SET @BasicDate = @pBasicDate
	SET @InvoiceNo = @pInvoiceNo
	SET @ToSWarehouse =@pToSWarehouse
	SET @IsConfirm = @pIsConfirm
	SET @DateConfirm =@pDateConfirm
	
	
	--SELECT
	--		@OldStationeyCode = SPIOH.StationeyCode,
	--		@OldSWarehouse = SPIOH.SWarehouse,
	--		@OldQuanlity = ISNULL(SPIOH.Quanlity,0)
	--FROM
	--		Stb_StationeryIOHistory SPIOH
	--WHERE
	--		SPIOH.SIOHistoryNo = @SIOHistoryNo
			
			
	
	IF @IUD_FLAG = 'INSERT' BEGIN
	
		EXEC SmartFramework.dbo.usp_DoCreateSerial 'Stb_StationeryIOHistory', @SIOHistoryNo OUTPUT
		
		
		INSERT INTO Stb_StationeryIOHistory
		(
		    SIOHistoryNo,
		    CompanyCode,
		    WorkCenterCode,
		    SWarehouse,
		    SIOTypeCode,
		    
		    StationeyCode,
		    VendorCode,
		    UnitPrice,
		    Quanlity,
		    Dept,
			Purpose,
			Description,
		    CreateDateTime,
		    CreateUserID,

			LineCode,
			EmpNo,
			Attribute1,
			Attribute2 ,
			Attribute3,
			Attribute4 ,
			Attribute5 ,
			BasicDate,
			InvoiceNo,
			ToSWarehouse,
			IsConfirm,
			DateConfirm
			
		)
		VALUES
		(
		    @SIOHistoryNo,
		    @CompanyCode,
		    @WorkCenterCode,
		    @SWarehouse,
		    @SIOTypeCode,

		    @StationeyCode,
		    @VendorCode,
		    @UnitPrice,
		    @Quanlity,
		    @Dept,
			@Purpose,
			@Description,

		    GETDATE(),
		    @pProcessUserID,


			@LineCode,
			@EmpNo,
			@Attribute1,
			@Attribute2,
			@Attribute3,
			@Attribute4,
			@Attribute5,
			@BasicDate,
			@InvoiceNo,
			@ToSWarehouse,
			@IsConfirm,
			@DateConfirm
		)
		
	
		
	END ELSE
	IF @IUD_FLAG = 'UPDATE' BEGIN
					
        UPDATE Stb_StationeryIOHistory
		SET
		    SIOHistoryNo =   CASE
		                WHEN @SIOHistoryNo IS NOT NULL THEN @SIOHistoryNo
		                ELSE SIOHistoryNo
		            END,
		    CompanyCode =   CASE
		                WHEN @CompanyCode IS NOT NULL THEN @CompanyCode
		                ELSE CompanyCode
		            END,
		    WorkCenterCode =   CASE
		                WHEN @WorkCenterCode IS NOT NULL THEN @WorkCenterCode
		                ELSE WorkCenterCode
		            END,
		    SWarehouse =   CASE
		                WHEN @SWarehouse IS NOT NULL THEN @SWarehouse
		                ELSE SWarehouse
		            END,
		    SIOTypeCode =   CASE
		                WHEN @SIOTypeCode IS NOT NULL THEN @SIOTypeCode
		                ELSE SIOTypeCode
		            END,
		    StationeyCode =   CASE
		                WHEN @StationeyCode IS NOT NULL THEN @StationeyCode
		                ELSE StationeyCode
		            END,
		    VendorCode =   CASE
		                WHEN @VendorCode IS NOT NULL THEN @VendorCode
		                ELSE VendorCode
		            END,
		    UnitPrice =   CASE
		                WHEN @UnitPrice IS NOT NULL THEN @UnitPrice
		                ELSE UnitPrice
		            END,
		    Quanlity =   CASE
		                WHEN @Quanlity IS NOT NULL THEN @Quanlity
		                ELSE Quanlity
		            END,
		    Dept =   CASE
		                WHEN @Dept IS NOT NULL THEN @Dept
		                ELSE Dept
		            END,
			Purpose =   CASE
		                WHEN @Purpose IS NOT NULL THEN @Purpose
		                ELSE Purpose
		            END,
			Description =   CASE
		                WHEN @Description IS NOT NULL THEN @Description
		                ELSE Description
		            END,
			LineCode =   CASE
		                WHEN @LineCode IS NOT NULL THEN @LineCode
		                ELSE LineCode
		            END,
			EmpNo =   CASE
		                WHEN @EmpNo IS NOT NULL THEN @EmpNo
		                ELSE EmpNo
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
			ToSWarehouse = CASE	
						WHEN @ToSWarehouse IS NOT NULL THEN @ToSWarehouse
						ELSE ToSWarehouse
				        END,
		    ChangeDateTime = GETDATE(),
		    ChangeUserID = @pProcessUserID,
			IsConfirm = CASE
						WHEN @IsConfirm IS NOT NULL THEN @IsConfirm
						ELSE IsConfirm
						END,
			DateConfirm = CASE	
						WHEN @DateConfirm is not null then @DateConfirm
						ELSE DateConfirm
						END
		WHERE
		    SIOHistoryNo = @OldSIOHistoryNo
		    
		    
		    
	END ELSE 
	IF @IUD_FLAG = 'DELETE' BEGIN
		
        DELETE FROM Stb_StationeryIOHistory
		WHERE
		    SIOHistoryNo = @SIOHistoryNo
		  
	END
	
END

