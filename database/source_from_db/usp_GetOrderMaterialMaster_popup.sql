-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-02-17
-- Group : 팝업
-- Description:	품목마스터정보(발주자재) 팝업용
-- =============================================
--  EXEC usp_GetOrderMaterialMaster_popup 'V0142'

CREATE PROCEDURE [dbo].[usp_GetOrderMaterialMaster_popup]
	@pCustomerCode VARCHAR(20) = NULL
AS

BEGIN

	SET NOCOUNT ON;

	DECLARE @CustomerCode VARCHAR(20) = @pCustomerCode
			
	SELECT
			MM.MaterialCode,
			MM.MaterialName,
			MM.MaterialNameL,
			MM.MaterialUnit,
			MM.BasicGrQty,
			MM.MaterialSpec,
			MM.MaterialSpecL,
			MM.MaterialSource,
			MM.AvgGrDay
	FROM
			               STB_MaterialMaster MM WITH(NOLOCK)
			INNER JOIN STB_MaterialVendorMapping MVM WITH(NOLOCK)				ON MVM.MaterialCode = MM.MaterialCode AND				MVM.CustomerCode = @CustomerCode
	WHERE 1=1
		AND	(MM.IsOrder = 1)                                 -- 자재정보에서  발주자재정보
		AND	(ISNULL(MM.IsClosed, CONVERT(BIT, 0)) = 0) 
		AND	(MVM.IsUsed = 1)


END