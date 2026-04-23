


-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-05-29
-- Browsable : true
-- Group : 금형관리
-- Description:	금형타각이미지 상세 조회
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetMoldMarkDetailHistory]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pMoldNumber VARCHAR(50) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	
    DECLARE @MoldNumber VARCHAR(50) = CASE WHEN ISNULL(@pMoldNumber,'') = '' THEN '*' ELSE @pMoldNumber END
	
	
	
	SELECT
			MMH.MoldMarkHistNo AS OldMoldMarkHistNo,
			MMH.MoldMarkHistNo,
			
			MMH.MoldNumber AS OldMoldNumber,
			MMH.MoldNumber,
			
			MBI.CompanyCode AS MoldCompanyCode,			--현재 금형이 위치하고 있는 사업장
			MOLD_CI.CompanyName AS MoldCompanyName,		--현재 금형이 위치하고 있는 사업장명
			MOLD_CI.CompanyNameL AS MoldCompanyNameL,	--현재 금형이 위치하고 있는 사업장타언어
			
			MBI.WorkCenterCode AS MoldWorkCenterCode,		--현재 금형이 위치하고 있는 작업장
			MOLD_WC.WorkCenterName AS MoldWorkCenterName,	--현재 금형이 위치하고 있는 작업장명
			MOLD_WC.WorkCenterNameL AS MoldWorkCenterNameL,	--현재 금형이 위치하고 있는 작업장타언어
			
			MMH.CompanyCode,							--타각이미지 등록 사업장
			MARK_CI.CompanyName AS CompanyName,			--타각이미지 등록 사업장명
			MARK_CI.CompanyNameL AS CompanyNameL,		--타각이미지 등록 사업장타언어
			
			MMH.WorkCenterCode AS WorkCenterCode,		--타각이미지 등록 작업장
			MARK_WC.WorkCenterName AS WorkCenterName,	--타각이미지 등록 작업장명
			MARK_WC.WorkCenterNameL AS WorkCenterNameL, --타각이미지 등록 작업장타언어
			
			MMH.BasicDate,
			MMH.FileID, 
			AFM.[FileName],
			AFM.FileSize,
			CONVERT(VARBINARY(MAX),NULL) AS FileData,
			MMH.DescText,
			MMH.CreateDateTime,
			MMH.CreateUserID,
			MMH.ChangeDateTime,
			MMH.ChangeUserID
	FROM
	
			STB_MoldMarkHistory MMH WITH(NOLOCK)
			LEFT OUTER JOIN STB_MoldBasicInfo MBI WITH(NOLOCK)
				ON MBI.MoldNumber = MMH.MoldNumber
			LEFT OUTER JOIN STB_WorkCenterInfo MARK_WC WITH(NOLOCK)
				ON (MARK_WC.WorkCenterCode = MMH.WorkCenterCode)
			LEFT OUTER JOIN STB_WorkCenterInfo MOLD_WC WITH(NOLOCK)
				ON (MOLD_WC.WorkCenterCode = MBI.WorkCenterCode)
			LEFT OUTER JOIN STB_CompanyInfo MARK_CI WITH(NOLOCK)
				ON MARK_CI.CompanyCode = MMH.CompanyCode
			LEFT OUTER JOIN STB_CompanyInfo MOLD_CI WITH(NOLOCK)
				ON MOLD_CI.CompanyCode = MBI.CompanyCode
			LEFT OUTER JOIN SmartFramework_File.dbo.STB_AttachedFileMaster AFM WITH(NOLOCK)
				ON AFM.FileID = MMH.FileID
	WHERE
			
			((@MoldNumber = '*') OR (MMH.MoldNumber = @MoldNumber))
	
	ORDER BY
			MMH.BasicDate DESC,
			MMH.CreateDateTime DESC
	
END




