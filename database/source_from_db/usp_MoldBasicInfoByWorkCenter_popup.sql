
-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date:  2016-05-04
-- Browsable : true
-- Group : 팝업
-- Description:	사업장,작업장에 해당하는 금형번호 조회용 팝업
-- =============================================
CREATE PROCEDURE [dbo].[usp_MoldBasicInfoByWorkCenter_popup]
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL
AS
BEGIN
	
	SET NOCOUNT ON;
	
	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
	DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END
	
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
			MBI.AlarmStatus,
			MBI.WorkCenterCode,
			WCI.WorkCenterName
	FROM
			STB_MoldBasicInfo MBI WITH(NOLOCK)
			LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)
				ON WCI.WorkCenterCode = MBI.WorkCenterCode
	WHERE
			
			((@CompanyCode = '*') OR (MBI.CompanyCode = @CompanyCode))
			AND ((@WorkCenterCode = '*') OR (MBI.WorkCenterCode = @WorkCenterCode))

			
END



