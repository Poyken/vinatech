
-- =============================================
-- Author:	    Yu Young Jong(yuyj@vina.co.kr)
-- Create date: 2018-09-12
-- Browsable : true
-- Group : 현장용
-- Description:	오븐출고 IUD
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_OvenOutput_iud]
	@pBarcode VARCHAR(20)
AS
BEGIN
	Declare @barcode varchar(20), @ovenInputDateTime varchar(19), @rtnMsg varchar(50)

	SET @barcode = @pBarcode
	SELECT @ovenInputDateTime = SIExtText02 FROM STB_SetInfo WHERE Barcode = @barcode

	IF @@ROWCOUNT = 0 
	BEGIN
		SET @rtnMsg = '존재하지 않는 LOT입니다. ('+@barcode+')' 
		
		RAISERROR(@rtnMsg, 16, 1)
		RETURN
	END

	IF ISNULL(@ovenInputDateTime, '') = '' 
	BEGIN
		SET @rtnMsg = '입고시간이 없는 LOT입니다. ('+@barcode+')' 

		RAISERROR(@rtnMsg, 16, 1)
		RETURN
	END

	UPDATE STB_SetInfo SET SIExtText03 = CONVERT(CHAR(19), getdate(), 121) WHERE Barcode = @barcode
END
