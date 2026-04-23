

-- =============================================
-- Author: Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-09-18
-- Browsable : true
-- Group : 팝업
-- Description:	거래선(외주사) 팝업
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_CustomerInfoBySourcing_popup]
WITH RECOMPILE
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
			CI.CustomerCode,
			CI.CustomerName,
			CI.AddressText,
			CI.TelNo,
			CI.MaterialWarehouseCode,
			MW.MaterialWarehouseName
	FROM
			STB_CustomerInfo CI WITH(NOLOCK)
			LEFT OUTER JOIN STB_MaterialWarehouse MW WITH(NOLOCK)
				ON MW.MaterialWarehouseCode = CI.MaterialWarehouseCode
	WHERE
			CI.IsUsed = 1
			AND CI.IsSourcing = 1
END