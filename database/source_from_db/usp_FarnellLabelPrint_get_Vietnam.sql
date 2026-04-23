-- =============================================
-- Author:		Mr.Manh
-- Create date: 2025-10-07
-- Description:	In tem khách hàng Farnell
-- =============================================
CREATE PROCEDURE [dbo].[usp_FarnellLabelPrint_get_Vietnam]	-- usp_FarnellLabelPrint_get_Vietnam '', '', '', '' ,'','','', 'MVVQL156R025504', '1'
	-- Add the parameters for the stored procedure here
		@pProcessUserID VARCHAR(20)=null,
		@pProcessLanguage VARCHAR(20)=null,
		@pCustomerPO VARCHAR(50)=null,
		@pPackingListNumber VARCHAR(50)=null,
		@pCustomerPartNumber VARCHAR(50) = NULL,
		@pSupplierPartNumber VARCHAR(50) = NULL,
		@pQuantity VARCHAR(10) = NULL,
		@pLotNo VARCHAR(50) = NULL,
		@pSerialNumber VARCHAR(50) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
	DECLARE	@LotNo VARCHAR(50) = @pLotNo
		,@IsProdFinish BIT
		,@CheckMPN VARCHAR(30)
		,@SN VARCHAR(20)
		,@RowCnt INT

	-- update 2025-10-13, can search Lotno Changed 
	DECLARE @NewBarcode VARCHAR(30) = NULL
	SELECT @NewBarcode = NewBarcode FROM STB_LotChangeMaterialHistory WHERE OldBarcode = @LotNo



	-- Check LotNo
	SELECT @IsProdFinish = IsProdFinish
			--@CheckMPN = RTRIM(LTRIM(SUBSTRING(MM.MaterialName, CHARINDEX(' ', MM.MaterialName), 12))) + CASE WHEN CHARINDEX('-L', MM.MaterialName) > 0 THEN '-L' ELSE '' END 
	  FROM STB_SetInfo SI WITH(NOLOCK)
	LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)	ON MM.MaterialCode = SI.MaterialCode
	 WHERE Barcode = @LotNo or Barcode = @NewBarcode		-- update 2025-10-13, can search Lotno Changed 
	 --OR @LotNo IN ('MVVQL156R025504')



	IF @@ROWCOUNT = 0 BEGIN
		SELECT @IsProdFinish = IsProdFinish
		  FROM STB_SetInfo
		 WHERE Barcode = REPLACE(@LotNo, 'VV', 'VV')
	END

	--IF @pTypeBoxCode IS NULL or @pTypeBoxCode = '' BEGIN
	--	EXEC usp_RaiseLocalizedError @pProcessLanguage, N'Hãy chọn loại thùng để in tem'
	--	RETURN
	--END

	--IF @LotNo NOT IN ('MVVQL156R025504')
	--BEGIN
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
	--END

	--Tự gen DateCode
	DECLARE @rDC VARCHAR(4) = NULL
	SET @rDC = dbo.fnGetWeekNumber(CONVERT(DATE, dbo.fnPharseLotNo(@LotNo, 'D'), 112))

	-- Tạo bảng
		SELECT
			ISNULL(@pCustomerPO, '') AS CustomerPO,
			ISNULL(@pPackingListNumber, '') AS PackingListNumber,
			ISNULL(@pCustomerPartNumber, '') AS CustomerPartNumber,
			ISNULL(@pSupplierPartNumber, '') AS SupplierPartNumber,
			ISNULL(@pQuantity, '') AS Quantity,
			ISNULL(@rDC, '') AS DateCodes,
			ISNULL(@pLotNo, '') AS LotCodes,
			ISNULL(@pSerialNumber, '') AS SerialNumber,
			0 AS ProdLabelQty,
			0 AS LogLabelQty,
			'Report' AS CommandType


END
