-- =============================================
-- Author:	Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-05-18
-- Browsable : true
-- Group : 팝업
-- Description:	스페어파트 정보-팝업용
-- =============================================
CREATE PROCEDURE [dbo].[usp_SparePartInfo_popup] 
WITH RECOMPILE
AS
BEGIN

	SET NOCOUNT ON;
	
	
	SELECT
			SPI.SparePartCode,
			SPI.SparePartName,
			SPI.SparePartSpec01,
			SPI.SparePartSpec02,
			SPI.SparePartSpec03,
			SPI.SparePartSpec04,
			SPI.SparePartSpec05,
			SPI.SparePartImage,
			SPI.BasicUnitPrice,
			SPI.BasicDeliveryDay,
			SPI.BasicUnit,
			SPI.SafeQty,
			SPI.LastDeliveryVendor,
			SPI.CompatibilityGroup
	FROM
			STB_SparePartInfo SPI WITH(NOLOCK)
			
	WHERE
			SPI.IsUsed = 1


END
