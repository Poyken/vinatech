-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-02-02
-- Browsable : true
-- Group : 팝업
-- Description:	금형보관위치 팝업
-- =============================================
CREATE PROCEDURE [dbo].[usp_MoldLocation_popup]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
			ML.MoldLocationCode,
			ML.CompanyCode,
			ML.WorkCenterCode,
			ML.LocationName,
			ML.LocationDesc1,
			ML.LocationDesc2
	FROM
			STB_MoldLocation ML WITH(NOLOCK)
		
END



