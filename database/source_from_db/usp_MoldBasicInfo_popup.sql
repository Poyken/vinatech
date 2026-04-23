

-- =============================================
-- Author:		Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date:  2018-09-05
-- Browsable : true
-- Group : 팝업
-- Description:	금형번호 조회용 팝업
-- =============================================
CREATE PROCEDURE [dbo].[usp_MoldBasicInfo_popup]
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL
AS
BEGIN
	
	SET NOCOUNT ON;

	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '%' ELSE @pCompanyCode END
	DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '%' ELSE @pWorkCenterCode END

	SELECT
			MBI.MoldNumber,
			MBI.MoldCategory1,
			MBI.MoldCategory2,
			MBI.MoldCategory3,
			MBI.MoldCategory4,
			MBI.MoldTypeCode,
			MBI.RawMaterial,
			MBI.MakeDate,
			MBI.MakeVendor,
			MBI.CurrentPosition,
			MBI.MoldGrade,
			MBI.GuaranteeQty,
			MBI.AccumulateQty,
			MBI.CurrentQty,
			MBI.AlarmStatus
	FROM
			STB_MoldBasicInfo MBI WITH(NOLOCK)
	WHERE
			MBI.CompanyCode LIKE @CompanyCode AND
			MBI.WorkCenterCode LIKE @WorkCenterCode	
END



