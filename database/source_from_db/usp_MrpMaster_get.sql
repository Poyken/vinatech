

-- =============================================
-- Author:	    Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2016-07-29
-- Browsable : true
-- Group : 자재관리
-- Description:	MRP 헤더정보를 가져옵니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MrpMaster_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
	@pFromDate DATE = NULL,
	@pToDate DATE = NULL

AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
	DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END
	DECLARE @FromDate DATE = ISNULL(@pFromDate, GETDATE())
	DECLARE @ToDate DATE = ISNULL(@pToDate, GETDATE())

    
	SELECT
			MM.MrpNo AS OldMrpNo,
			MM.MrpNo,
			MSMS.MaterialCode,
			MMS.MaterialName,
			MM.CompanyCode,
			CI.CompanyName,
			MM.WorkCenterCode,
			WCI.WorkCenterName,
			MM.BasicDate,
			MM.MrpDesc,
			MM.IsUseMrpProdDate,
			MM.MrpProdDate,
			MM.IsRunMrp,
			MM.MrpRunDateTime,
			MM.MrpRunUserID,
			MM.IsFixedMRP,
			ISNULL(MM.IsCancel, 0) AS IsCancel,
			MM.MrpFixDateTime,
			MM.MrpFixUserID,
			MM.CreateDateTime,
			MM.CreateUserID,
			MM.ChangeDateTime,
			MM.ChangeUserID
	FROM
			STB_MrpMaster MM WITH(NOLOCK)
			LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK)
				ON	CI.CompanyCode = MM.CompanyCode
			LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)
				ON	WCI.WorkCenterCode = MM.WorkCenterCode
			LEFT OUTER JOIN
			(
				SELECT
						MSM.MrpNo,
						MAX(MSM.MaterialCode) AS MaterialCode
				FROM
						STB_MrpSourceMaterial MSM WITH(NOLOCK)
				GROUP BY
						MSM.MrpNo
			) MSMS
				ON MSMS.MrpNo = MM.MrpNo
			LEFT OUTER JOIN STB_MaterialMaster MMS WITH(NOLOCK)
				ON MMS.MaterialCode = MSMS.MaterialCode
	WHERE
			((@CompanyCode = '*') OR (MM.CompanyCode = @CompanyCode)) AND
			((@WorkCenterCode = '*') OR (MM.WorkCenterCode = @WorkCenterCode)) AND
			(MM.BasicDate BETWEEN @FromDate AND @ToDate)

END
