-- =============================================
-- Author:		Nguyễn Hải Triều
-- Create date: 2025-09-20
-- Description:	In tem InnerBox
-- =============================================
CREATE PROCEDURE [dbo].[usp_getPrinterInnerBox_VVT_F3]
	-- Add the parameters for the stored procedure here
	@pProcessUserID VARCHAR(20)=null,
	@pProcessLanguage VARCHAR(20)=null,
	@pCustomerPartNumber VARCHAR(50)=null,
	@pSupplier VARCHAR(50)=null,
	@pCustomerPO VARCHAR(50)=NULL,
	@pMoisture INT=1,
	@pQuantity INT=1,
	@pDateCodes DATETIME,
	@pLotCodes VARCHAR(50)=null,
	@pSerialNumber VARCHAR(50)=null,
	@pPrintCount INT = 1 

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @CustomerPartNumber VARCHAR(50);
	DECLARE @CustomerPO VARCHAR(50);
	DECLARE @Supplier VARCHAR(50);
	DECLARE @Moisture VARCHAR(50);
	DECLARE @LotCodes VARCHAR(50);
	DECLARE @SerialNumber VARCHAR(50);
    DECLARE @Barcode VARCHAR(1000);    
	DECLARE @Quantity VARCHAR(50);
    DECLARE @DateCodesLabel VARCHAR(50);
	DECLARE @DateCodes VARCHAR(50);
	-- lay tu dong theo max

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
	 SET @CustomerPO        = CONCAT('K',   @pCustomerPO);
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
    @Supplier,
	@CustomerPO,
    @Moisture,
    @Quantity,
    @DateCodesLabel,
	@SerialNumber,
    @LotCodes
  
);
  

	   IF (@CompanyCode='VVT' and @WorkCenterCode in ('VVT_F3') ) 
		BEGIN
			 CREATE TABLE #tmpLabel (Num INT);

				DECLARE @i INT = 1;
				WHILE @i <= @pPrintCount
				BEGIN
					INSERT INTO #tmpLabel VALUES(@i);
					SET @i = @i + 1;
				END

				-- Xuất kết quả
				SELECT  
					@pCustomerPartNumber AS MaterialCodeCustomer,
					@pSupplier AS MaterialCode,
					@pCustomerPO AS CustomerPO,
					@pMoisture AS Moisture,
					@pQuantity AS CurrentQty,         
					@DateCodes AS DateCodes,     
					@pLotCodes AS MarkingLetter,
					@pSerialNumber AS SerialNumber,
					@Barcode AS QRCode,
					'Report' AS CommandType,
					Num AS PrintOrder
				FROM #tmpLabel;

				DROP TABLE #tmpLabel;
		END


		-- Mr.Manh update 25-10-07
	ELSE IF (@CompanyCode='VVT' and @WorkCenterCode in ('VVT_F1', 'VVT_F2') ) 
		BEGIN

			SET @rDC = dbo.fnGetWeekNumber(CONVERT(DATE, dbo.fnPharseLotNo(@pLotCodes, 'D'), 112))

			SET @rDCLabel = CASE WHEN @rDC = '' THEN '' ELSE CONCAT('10D', @rDC) END;

			 SET @Barcode = CONCAT(
					')>06',
					@CustomerPartNumber,
					@Supplier,
					@CustomerPO,
					--@Moisture,
					@Quantity,
					@rDCLabel,		-- YYWW
					@SerialNumber,
					@LotCodes
  
				);
			 CREATE TABLE #tmpLabel1 (Num INT);

				DECLARE @ii INT = 1;
				WHILE @ii <= @pPrintCount
				BEGIN
					INSERT INTO #tmpLabel1 VALUES(@ii);
					SET @ii = @ii + 1;
				END

				-- Xuất kết quả
				SELECT  
					@pCustomerPartNumber AS MaterialCodeCustomer,
					@pSupplier AS MaterialCode,
					@pCustomerPO AS CustomerPO,
					'' AS Moisture,
					@pQuantity AS CurrentQty,         
					@rDC AS DateCodes,     -- YYWW
					@pLotCodes AS MarkingLetter,
					@pSerialNumber AS SerialNumber,
					@Barcode AS QRCode,
					'Report' AS CommandType,
					Num AS PrintOrder
				FROM #tmpLabel1;

				DROP TABLE #tmpLabel1;
		END


END
