-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-06-19
-- Browsable : true
-- Group : 금형관리
-- Description:	금형문제점개선시트정보를 조회합니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MoldImprovementSheet_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,
	@pCompanyName NVARCHAR(50) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
	@pWorkCenterName NVARCHAR(50) = NULL,
	@pMoldNumber VARCHAR(50) = NULL,
	@pFromDate DATE = NULL,
	@pToDate DATE = NULL
WITH RECOMPILE
AS
BEGIN

	SET NOCOUNT ON;
	
	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
	DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END
	DECLARE @MoldNumber VARCHAR(50) = CASE WHEN ISNULL(@pMoldNumber,'') = '' THEN '*' ELSE @pMoldNumber END
	DECLARE @FromDate DATE = CASE WHEN ISNULL(@pFromDate,'') = '' THEN GETDATE() ELSE @pFromDate END
	DECLARE @ToDate DATE = CASE WHEN ISNULL(@pToDate,'') = '' THEN GETDATE() ELSE @pToDate END
		
	

	SELECT
			MIS.ImproveHistNo AS OldImproveHistNo,
			MIS.ImproveHistNo,
			MIS.MoldSeqNo,
			MBI.CompanyCode,
			CI.CompanyName,
			MIS.WorkCenterCode,
			WCI.WorkCenterName,
			
			MIS.MoldNumber,
			MBI.MoldCategory1,						--차종
			MBI.MoldCategory2,						--품명
			MBI.MoldCategory3,						--규격
			
			MIS.ImprovementStep,
			VIS.ImprovementStepName,
			--CASE WHEN MIS.ImprovementStep = '1' THEN '일상점검'
			--	 WHEN MIS.ImprovementStep = '2' THEN '세척'
			--	 WHEN MIS.ImprovementStep = '3' THEN '습합'
			--	 WHEN MIS.ImprovementStep = '4' THEN '오버홀'
			--END ImprovementStepName,
			MIS.ImprovementType,
			
			MIS.MoldType,
			VMT.MoldTypeName,
			--CASE WHEN MIS.MoldType = '1' THEN '프레스'
			--	 WHEN MIS.MoldType = '2' THEN '사출'
			--	 WHEN MIS.MoldType = '3' THEN '다이캐스팅'
			--END MoldTypeName,
			MIS.MoldGrade,
			MIS.MoldRoute,
			MIS.RegistDate,
			MIS.CompleteDate,
			ISNULL(MIS.DocFileID,0) AS DocFileID,
			MIS.DocFileName,
			AFM.FileContents AS FileData,
			MIS.CreateDateTime,
			MIS.CreateUserID,
			MIS.ChangeDateTime,
			MIS.ChangeUserID
	FROM
			STB_MoldImprovementSheet MIS WITH(NOLOCK)
			LEFT OUTER JOIN STB_MoldBasicInfo MBI WITH(NOLOCK)
				ON MBI.MoldNumber = MIS.MoldNumber
			LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)
				ON WCI.WorkCenterCode = MIS.WorkCenterCode
			LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK)
				ON CI.CompanyCode = MBI.CompanyCode
			LEFT OUTER JOIN VW_ImprovementStep VIS WITH(NOLOCK)
				ON VIS.ImprovementStep = MIS.ImprovementStep
			LEFT OUTER JOIN VW_MoldType VMT WITH(NOLOCK)
				ON VMT.MoldType = MIS.MoldType
			LEFT OUTER JOIN SmartFramework_File.dbo.STB_AttachedFileMaster AFM WITH (NOLOCK)
				ON (AFM.FileID = MIS.DocFileID)
			
	WHERE
			((MIS.RegistDate >= @FromDate) AND (MIS.RegistDate <= @ToDate))
			AND((@CompanyCode = '*') OR (MBI.CompanyCode = @CompanyCode))
			AND ((@WorkCenterCode = '*') OR (MIS.WorkCenterCode = @WorkCenterCode))
			AND ((@MoldNumber = '*') OR (MIS.MoldNumber = @MoldNumber))
	ORDER BY
			MIS.MoldNumber,
			MIS.MoldSeqNo 
	
END



