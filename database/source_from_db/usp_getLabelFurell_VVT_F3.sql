-- =============================================
-- Author:		Nguyễn Hải Triều
-- Create date: 2025-09-19
-- Description:	In tem thùng ngoai
-- =============================================
CREATE PROCEDURE [dbo].[usp_getLabelFurell_VVT_F3]
	@pProcessUserID VARCHAR(20)=null,
	@pProcessLanguage VARCHAR(20)=null,
	@pCustomerPartNumber VARCHAR(50)=null,
	@pDeliveryPackingListNumber VARCHAR(50)=null,
	@pSupplier VARCHAR(50)=null,
	@pMoisture INT=1,
	@pQuantity INT=1,
	@pDateCodes DATETIME,
	@pLotCodes VARCHAR(50)=null,
	@pSerialNumber VARCHAR(50)=null

AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @CustomerPartNumber VARCHAR(50);
	DECLARE @DeliveryPackingListNumber VARCHAR(50);
	DECLARE @Supplier VARCHAR(50);
	DECLARE @Moisture VARCHAR(50);
	DECLARE @LotCodes VARCHAR(50);
	DECLARE @SerialNumber VARCHAR(50);
    DECLARE @Barcode VARCHAR(1000);    
	DECLARE @Quantity VARCHAR(50);
    DECLARE @DateCodesLabel VARCHAR(50);
	DECLARE @DateCodes VARCHAR(50);
	-- lay tu dong theo max
	


	-- Mr.Manh update 2025-10-07 chia Vinatech riêng, Enesol riêng
	DECLARE @rDC VARCHAR(4) = NULL
	DECLARE @rDCLabel VARCHAR(50) = NULL
	DECLARE @CompanyCode VARCHAR(20)
	DECLARE @WorkCenterCode VARCHAR(20)

	SELECT  @CompanyCode = CompanyCode,
			@WorkCenterCode = WorkCenterCode  
	FROM  STB_UserInfo 
	where UserID=@pProcessUserID 
	

    -- Build từng field với prefix
    SET @CustomerPartNumber        = CONCAT('P',   @pCustomerPartNumber);
    SET @DeliveryPackingListNumber = CONCAT('11K', @pDeliveryPackingListNumber);
    SET @Supplier                  = CONCAT('1P',  @pSupplier);
    SET @Moisture                  = CONCAT('M',   CAST(@pMoisture AS VARCHAR(5)));
    --SET @DateCodesLabel            = CONCAT('10D', FORMAT(@pDateCodes,'yyMM')); 
    SET @LotCodes                  = CONCAT('1T',  @pLotCodes);
    SET @SerialNumber              = CONCAT('S',   @pSerialNumber);
	SET @Quantity                  = CONCAT('Q', CAST(@pQuantity AS VARCHAR(50)));
	--ECLARE @DateCodes VARCHAR(50)= FORMAT(@pDateCodes,'yyMM');
	SET @DateCodes = CASE WHEN @pDateCodes IS NULL THEN '' ELSE FORMAT(@pDateCodes, 'yyMM') END;
    SET @DateCodesLabel = CASE WHEN @DateCodes = '' THEN '' ELSE CONCAT('10D', @DateCodes) END;
    -- Ghép lại thành barcode string theo format
 SET @Barcode = CONCAT(
    ')>06',
    @CustomerPartNumber,
    @DeliveryPackingListNumber,
    @Supplier,
    @Moisture,
    @Quantity,
    @DateCodesLabel,
    @LotCodes,
	@SerialNumber
   
);
    IF (@CompanyCode='VVT' and @WorkCenterCode in ('VVT_F3') ) 
		BEGIN
			SELECT  
				@pCustomerPartNumber AS MaterialCodeCustomer,
				@pDeliveryPackingListNumber AS DeliveryPackingListNumber,
				@pSupplier AS MaterialCode,
				@PMoisture AS Moisture,
				@pQuantity AS CurrentQty,         
				@DateCodes AS DateCodes,     -- thêm cột string in tem
				@pLotCodes AS MarkingLetter,
				@pSerialNumber AS SerialNumber,
				@Barcode AS QRCode,
				'Report' AS CommandType
		END


		-- Mr.Manh update 25-10-07
	ELSE IF (@CompanyCode='VVT' and @WorkCenterCode in ('VVT_F1', 'VVT_F2') ) 
		BEGIN

			SET @rDC = dbo.fnGetWeekNumber(CONVERT(DATE, dbo.fnPharseLotNo(@pLotCodes, 'D'), 112))

			SET @rDCLabel = CASE WHEN @rDC = '' THEN '' ELSE CONCAT('10D', @rDC) END;

			SET @Barcode = CONCAT(
				')>06',
				@CustomerPartNumber,
				@DeliveryPackingListNumber,
				@Supplier,
				--@Moisture,
				@Quantity,
				@rDCLabel,  -- YYWW
				@LotCodes,
				@SerialNumber
			);
			SELECT  
				@pCustomerPartNumber AS MaterialCodeCustomer,
				@pDeliveryPackingListNumber AS DeliveryPackingListNumber,
				@pSupplier AS MaterialCode,
				'' AS Moisture,
				@pQuantity AS CurrentQty,         
				@rDC AS DateCodes,     -- YYWW
				@pLotCodes AS MarkingLetter,
				@pSerialNumber AS SerialNumber,
				@Barcode AS QRCode,
				'Report' AS CommandType
		END

		
END