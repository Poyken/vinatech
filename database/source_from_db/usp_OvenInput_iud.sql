
-- =============================================
-- Author:	    Yu Young Jong(yuyj@vina.co.kr)
-- Create date: 2018-09-12
-- Browsable : true
-- Group : 현장용
-- Description:	오븐입고 IUD
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_OvenInput_iud]
	@pBarcode VARCHAR(20)
AS
BEGIN
	Declare @barcode varchar(20), @rtnMsg varchar(50)

	SET @barcode = @pBarcode

	UPDATE STB_SetInfo SET SIExtText02 = CONVERT(CHAR(19), getdate(), 121) WHERE Barcode = @barcode

	IF @@ROWCOUNT = 0 
	BEGIN
		SET @rtnMsg = '존재하지 않는 LOT입니다. (' + @barcode + ')'

		RAISERROR (@rtnMsg, 16, 1)
	END
END
