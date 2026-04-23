-- =============================================
-- Author:		DinhManh
-- Create date: 2025-10-20
-- Description:	Print Label for Jabil Mexico Partner
-- =============================================
CREATE PROCEDURE [dbo].[usp_JabilMexicoLabelPrint_get_Vietnam] 
	-- Add the parameters for the stored procedure here
		@pProcessUserID VARCHAR(20) = null,
		@pProcessLanguage VARCHAR(20) = null,
		@pJabilPartNumber VARCHAR(50) = null,
		@pVinatechPartNumber VARCHAR(50) = null,
		@pPONumber VARCHAR(50) = NULL,
		@pLotNo VARCHAR(50) = NULL,
		@pQuantity VARCHAR(10) = NULL

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

		DECLARE	@LotNo VARCHAR(50) = @pLotNo
		,@IsProdFinish BIT
		,@CheckMPN VARCHAR(30)
		,@SN VARCHAR(20)
		,@RowCnt INT

	-- update 2025-10-13, có thể tìm được khi lotno đã đc chuyển đổi lot
	DECLARE @NewBarcode VARCHAR(30) = NULL
	SELECT @NewBarcode = NewBarcode FROM STB_LotChangeMaterialHistory WHERE OldBarcode = @LotNo



	-- Check LotNo
	SELECT @IsProdFinish = IsProdFinish
			--@CheckMPN = RTRIM(LTRIM(SUBSTRING(MM.MaterialName, CHARINDEX(' ', MM.MaterialName), 12))) + CASE WHEN CHARINDEX('-L', MM.MaterialName) > 0 THEN '-L' ELSE '' END 
	  FROM STB_SetInfo SI WITH(NOLOCK)
	LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)	ON MM.MaterialCode = SI.MaterialCode
	 WHERE Barcode = @LotNo or Barcode = @NewBarcode		-- update 2025-10-13, can search Lotno Changed 



	IF @@ROWCOUNT = 0 BEGIN
		SELECT @IsProdFinish = IsProdFinish
		  FROM STB_SetInfo
		 WHERE Barcode = REPLACE(@LotNo, 'VV', 'VV')
	END

	--IF @pTypeBoxCode IS NULL or @pTypeBoxCode = '' BEGIN
	--	EXEC usp_RaiseLocalizedError @pProcessLanguage, N'Hãy chọn loại thùng để in tem'
	--	RETURN
	--END


	------- Tắt đoạn này vì có những Lot bị đổi sau khi vào kho -- BEGIN
	IF @IsProdFinish IS NULL BEGIN 
		EXEC usp_RaiseLocalizedError @pProcessLanguage, N'Mã Lotno này không tồn tại trên hệ thống.!'
		RETURN
	END

	IF @IsProdFinish <> CONVERT(BIT, 1) BEGIN
		EXEC usp_RaiseLocalizedError @pProcessLanguage, N'Kiểm tra màn hình B523 xem đóng gói hay chưa. Gọi sản xuất'
		RETURN
	END

	------- Tắt đoạn này vì có những Lot bị đổi sau khi vào kho -- END


    	--Tự gen DateCode
	DECLARE @rDC VARCHAR(4) = NULL
	SET @rDC = dbo.fnGetWeekNumber(CONVERT(DATE, dbo.fnPharseLotNo(@LotNo, 'D'), 112))



	SELECT 
		ISNULL(@pJabilPartNumber, '') AS JabilPartNumber,
		ISNULL(@pVinatechPartNumber, '') AS ManufacturerPartNumber,
		ISNULL(@pPONumber, '') AS PONumber,
		ISNULL(@pQuantity, '') AS Quantity,
		ISNULL(@pLotNo, '') AS LotCode,
		ISNULL(@rDC, '') AS DateCode,
		'VN' AS CoO,
		'RoHS' AS MSL,
		0 AS LabelQty,
		'Report' AS CommandType

END
