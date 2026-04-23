

-- =============================================
-- Author:	    Yu Young Jong(yuyj@vina.co.kr)
-- Create date: 2018-09-12
-- Browsable : true
-- Group : 현장용
-- Description:	오븐 입출고 시간
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_OvenInOutDateTime_get]
	@pBarcode VARCHAR(20)
AS
BEGIN
	Declare @barcode varchar(20)

	SET @barcode = @pBarcode

	SELECT SIExtText02 AS OvenInputDateTime
	      ,SIExtText03 AS OvenOutputDateTime
		  ,SIExtText04 AS HighTempStoringInputDateTime
		  ,SIExtText05 AS HighTempStoringOutputDateTime
	  FROM STB_SetInfo
	 WHERE Barcode = @barcode
END
