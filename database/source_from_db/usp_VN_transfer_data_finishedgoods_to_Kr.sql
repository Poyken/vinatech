CREATE PROC [dbo].[usp_VN_transfer_data_finishedgoods_to_Kr]
	@pDateget NVARCHAR(5)
AS
BEGIN

	DECLARE @Days NVARCHAR(5) = @pDateget

	IF  Datepart(day,GETDATE()) = @Days  BEGIN

	DECLARE @COMPANY NVARCHAR(5) = 'VVT'
	DECLARE @WORKCENTERCODES NVARCHAR(12) = 'VVT_F1'
	DECLARE @MaterialWarehouseCodes NVARCHAR(20) = 'PROD_VN_WH'
	DECLARE @MaterialLocationCodes NVARCHAR(20) = 'PROD_VN_WH_01'
	DECLARE @CreateBy NVARCHAR(100) = 'The data transfer'
	DECLARE @ProductStockNo VARCHAR(20)
	DECLARE @MaterialCode NVARCHAR(50)
	DECLARE @LotNo NVARCHAR(50)
	DECLARE @PackingID NVARCHAR(50)
	DECLARE @PackQty INT
	DECLARE @CreateDateTime DATETIME
	DECLARE @CreateUserID NVARCHAR(50)
	DECLARE @Srt numeric

	DECLARE Cusproduction CURSOR FOR
		SELECT 
				@Srt,
				@COMPANY AS CompanyCode,
				@WORKCENTERCODES AS WorkCenterCode,
				MaterialCode,
				LotNo,
				PackingID,
				@MaterialWarehouseCodes AS MaterialWarehouseCode,
				@MaterialLocationCodes AS MaterialLocationCode,
				PackQty,
				GETDATE() AS CreateDateTime,
				@CreateBy AS CreateUserID
		
		FROM STB_VN_FINISHGOODS WITH(NOLOCK)

		WHERE Statusout IS NULL AND Flag = 1

		OPEN Cusproduction

		FETCH NEXT FROM Cusproduction

		INTO @Srt,@COMPANY,@WORKCENTERCODES,@MaterialCode,@LotNo,@PackingID,@MaterialWarehouseCodes,@MaterialLocationCodes,@PackQty,@CreateDateTime,@CreateUserID

		WHILE @@FETCH_STATUS = 0

		BEGIN
			-- In the case of initial input, it consists only of numbers without date information.
			-- If you count with MAX + 1, duplicates will occur with the automatically generated number.
			-- SELECT @Srt =   isnull(max(cast(ProductStockNo as numeric)),0) + 1 from STB_ProductStockInfoUpload
			EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_ProductStockInfoUpload', @ProductStockNo OUTPUT

			INSERT INTO STB_ProductStockInfoUpload (ProductStockNo,CompanyCode,WorkCenterCode,MaterialCode,Barcode,PackingID,MaterialWarehouseCode,MaterialLocationCode,StockQty,CreateDateTime,CreateUserID)
			VALUES (@ProductStockNo,@COMPANY,@WORKCENTERCODES,@MaterialCode,@LotNo,@PackingID,@MaterialWarehouseCodes,@MaterialLocationCodes,@PackQty,@CreateDateTime,@CreateUserID)

			FETCH NEXT FROM Cusproduction
			INTO @Srt,@COMPANY,@WORKCENTERCODES,@MaterialCode,@LotNo,@PackingID,@MaterialWarehouseCodes,@MaterialLocationCodes,@PackQty,@CreateDateTime,@CreateUserID

		END

		CLOSE Cusproduction              
		DEALLOCATE Cusproduction   

	END
END
