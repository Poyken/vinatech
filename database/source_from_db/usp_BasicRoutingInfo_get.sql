-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2016-01-28
-- Browsable : true
-- Group : 공통
-- Description:	BOM Detail 조회 프로시저
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_BasicRoutingInfo_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '%' ELSE @pCompanyCode END
	DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '%' ELSE @pWorkCenterCode END
 
	SELECT
			BRI.CompanyCode,
			--CI.CompanyName,
			BRI.WorkCenterCode,
			--WCI.WorkCenterName,
			BRI.BasicRoutingCode AS OldBasicRoutingCode,
			BRI.BasicRoutingCode,
			BRI.BasicRoutingName,
			BRI.BasicRoutingDesc,
			BRI.IsUsed,
			BRI.CreateDateTime,
			BRI.CreateUserID,
			BRI.ChangeDateTime,
			BRI.ChangeUserID
	FROM
			STB_BasicRoutingInfo BRI WITH(NOLOCK)
	-- 사업장 코드와 작업장 코드를 Detail 테이블로 이동함.
	--		LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK)
	--			ON CI.CompanyCode = BRI.CompanyCode
	--		LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)
	--			ON WCI.WorkCenterCode = BRI.WorkCenterCode
	--WHERE
	--		BRI.CompanyCode LIKE @CompanyCode AND
	--		BRI.WorkCenterCode LIKE @WorkCenterCode
    
END
