-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-06-14
-- Browsable : true
-- Group : 금형관리
-- Description:	금형보관이력정보 조회
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MoldMoveHist_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
	@pFromMoveDate DATE = NULL,
	@pToMoveDate DATE = NULL
AS
BEGIN

	SET NOCOUNT ON;
	
	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
	DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END
	DECLARE @FromMoveDate DATE = CASE WHEN ISNULL(@pFromMoveDate,'') = '' THEN GETDATE() ELSE @pFromMoveDate END
	DECLARE @ToMoveDate DATE = CASE WHEN ISNULL(@pToMoveDate,'') = '' THEN GETDATE() ELSE @pToMoveDate END
	
	SELECT
			MMH.MoldMoveHistNo AS OldMoldMoveHistNo,
			MMH.MoldMoveHistNo,
			MMH.CompanyCode,
			CI.CompanyName,
			CI.CompanyNameL,
			MMH.WorkCenterCode,
			WCI.WorkCenterName,
			WCI.WorkCenterNameL,
			MMH.MoldNumber,
			MBI.MoldCategory1,
			MBI.MoldCategory2,
			MBI.MoldCategory3,
			MMH.MoveBasicDate,
			MMH.MoldMoveTypeCode,
			MMT.MoldMoveTypeName,
			MMH.MoldLocationCode,
			ML.LocationName AS MoldLocationName,
			MMH.TargetWorkCenterCode,
			TargetWCI.WorkCenterName AS TargetWorkCenterName,
			TargetWCI.WorkCenterNameL AS TargetWorkCenterNameL,
			MMH.ReturnBasicDate,
			MMH.ManagerID,
			MMH.MoveDesc,
			MMH.MoveProcessDateTime,
			MMH.CreateDateTime,
			MMH.CreateUserID,
			MMH.ChangeDateTime,
			MMH.ChangeUserID
			
	FROM
			STB_MoldMoveHist MMH WITH(NOLOCK)
			LEFT OUTER JOIN STB_MoldBasicInfo MBI WITH(NOLOCK)
				ON MBI.MoldNumber = MMH.MoldNumber
			LEFT OUTER JOIN STB_MoldMoveType MMT WITH(NOLOCK)
				ON MMT.MoldMoveTypeCode = MMH.MoldMoveTypeCode
			LEFT OUTER JOIN STB_MoldLocation ML WITH(NOLOCK)
				ON ML.MoldLocationCode = MMH.MoldLocationCode
			LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)
				ON WCI.WorkCenterCode = MMH.WorkCenterCode
			LEFT OUTER JOIN STB_WorkCenterInfo TargetWCI WITH(NOLOCK)
				ON TargetWCI.WorkCenterCode = MMH.TargetWorkCenterCode
			LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK)
				ON CI.CompanyCode = MMH.CompanyCode
	WHERE
			((@FromMoveDate <= MMH.MoveBasicDate) AND (MMH.MoveBasicDate <= @ToMoveDate)) AND
			((@CompanyCode = '*') OR (MMH.CompanyCode = @CompanyCode)) AND
			((@WorkCenterCode = '*') OR (MMH.WorkCenterCode = @WorkCenterCode))
    
END


