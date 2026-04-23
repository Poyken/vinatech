


-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-05-29
-- Browsable : true
-- Group : 금형관리
-- Description:	금형타각이미지 조회
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MoldMarkHistory_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,
	@pCompanyName NVARCHAR(50) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
	@pWorkCenterName NVARCHAR(50) = NULL,
	@pMoldNumber VARCHAR(50) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	
	
	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
    DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END
    DECLARE @MoldNumber VARCHAR(50) = CASE WHEN ISNULL(@pMoldNumber,'') = '' THEN '*' ELSE @pMoldNumber END
	
	
	
	SELECT
			MMH.MoldMarkHistNo,
			
			MBI.CompanyCode,
			CI.CompanyName,
			CI.CompanyNameL,
			
			MBI.WorkCenterCode,
			WCI.WorkCenterName,
			WCI.WorkCenterNameL,
			
			MBI.MoldNumber AS OldMoldNumber,
			MBI.MoldNumber,
			MBI.MoldCategory1,
			MBI.MoldCategory2,
			MBI.MoldCategory3,
			MBI.MoldCategory4,
			MBI.RawMaterial,
			MBI.MakeDate,
			MBI.MakeVendor,
			MBI.CurrentPosition,
			MBI.MoldGrade,
			MBI.GuaranteeQty,
			MBI.CurrentQty,
			MBI.AlarmStatus,
			MBI.MBIExtText01,
			MBI.MBIExtText02,
			MBI.MBIExtText03,
			MBI.MBIExtText04,
			MBI.MBIExtText05,
			
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
			STB_MoldBasicInfo MBI WITH(NOLOCK)
			LEFT OUTER JOIN (
							SELECT 
									*, 
									ROW_NUMBER() OVER (PARTITION BY MoldNumber ORDER BY CreateDateTime DESC) AS Seq -- 하루에 여러 이미지 등록할수도 있으니 BasicDate -> CreateDateTime으로 변경 20150304 
							 FROM STB_MoldMarkHistory WITH(NOLOCK)
							) MMH
				ON ((MBI.MoldNumber = MMH.MoldNumber) AND (MMH.Seq = 1)) -- 최종추가일 기준
			LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)
				ON (WCI.WorkCenterCode = MBI.WorkCenterCode)
			LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK)
				ON (CI.CompanyCode = MBI.CompanyCode)
			LEFT OUTER JOIN SmartFramework_File.dbo.STB_AttachedFileMaster AFM WITH(NOLOCK)
				ON AFM.FileID = MMH.FileID
	WHERE
			((@CompanyCode = '*') OR (MBI.CompanyCode = @CompanyCode))
			AND ((@WorkCenterCode = '*') OR (MBI.WorkCenterCode = @WorkCenterCode)) -- 작업장 확인필요
			AND ((@MoldNumber = '*') OR (MBI.MoldNumber = @MoldNumber))
	
END




