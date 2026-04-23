-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-02-02
-- Browsable : true
-- Group : 금형관리
-- Description:	금형마스터정보 조회
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MoldBasicInfo_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pMoldNumber VARCHAR(20) = NULL,
    @pCompanyCode VARCHAR(20) = NULL,
    @pWorkCenterCode VARCHAR(20) = NULL,
    @pMoldTypeCode VARCHAR(20) = NULL,
    @pMoldCategory1 VARCHAR(100) = NULL,
    @pMoldCategory2 VARCHAR(100) = NULL,
    @pMoldCategory3 VARCHAR(100) = NULL

AS
BEGIN
	SET NOCOUNT ON;
      DECLARE @MoldNumber VARCHAR(20) = CASE WHEN ISNULL(@pMoldNumber,'') = '' THEN '*' ELSE @pMoldNumber END
      DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
      DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END
      DECLARE @MoldTypeCode VARCHAR(20) = CASE WHEN ISNULL(@pMoldTypeCode,'') = '' THEN '*' ELSE @pMoldTypeCode END
      DECLARE @MoldCategory1 VARCHAR(100) = CASE WHEN ISNULL(@pMoldCategory1,'') = '' THEN '*' ELSE @pMoldCategory1 END
      DECLARE @MoldCategory2 VARCHAR(100) = CASE WHEN ISNULL(@pMoldCategory2,'') = '' THEN '*' ELSE @pMoldCategory2 END
      DECLARE @MoldCategory3 VARCHAR(100) = CASE WHEN ISNULL(@pMoldCategory3,'') = '' THEN '*' ELSE @pMoldCategory3 END

    
	SELECT
	        MBI.MoldNumber AS OldMoldNumber,
	        MBI.MoldNumber,
	        MBI.CompanyCode,
	        CI.CompanyName,
	        CI.CompanyNameL,
	        CI.CompanyDesc,
	        CI.CompanyDescL,
	        MBI.WorkCenterCode,
	        WCI.WorkCenterName,
	        WCI.WorkCenterNameL,
	        WCI.WorkCenterDesc,
	        WCI.WorkCenterDescL,
	        MBI.MoldTypeCode,
	        MTI.MoldTypeName,
	        MTI.MoldTypeDesc,
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
	        MBI.AccumulateQty,
	        MBI.CurrentQty,
	        MBI.AlarmStatus,
	        MBI.MBIExtText01,
	        MBI.MBIExtText02,
	        MBI.MBIExtText03,
	        MBI.MBIExtText04,
	        MBI.MBIExtText05,
	        MBI.MBIExtImage01,
	        MBI.MBIExtImage02,
	        MBI.MBIExtImage03,
	        MBI.MBIExtImage04,
	        MBI.MBIExtImage05,
	        MBI.MoldLocationCode,
	        ML.LocationName,
	        ML.LocationDesc1,
	        ML.LocationDesc2,
	        MBI.RFTagID,
	        MBI.CheckTerm1,
	        MBI.CheckTerm2,
	        MBI.CheckTerm3,
	        MBI.MoldGradeTypeCode,
	        MGT.MoldGradeTypeName,
	        MGT.Level1Qty,
	        MGT.Level2Qty,
	        MGT.Level3Qty,
	        MBI.CheckSheetType1,
	        MBI.CheckSheetType2,
	        MBI.CheckSheetType3,
	        MBI.CheckSheetType4,
	        MBI.CreateDateTime,
	        MBI.CreateUserID,
	        MBI.ChangeDateTime,
	        MBI.ChangeUserID
	FROM
	        STB_MoldBasicInfo MBI WITH(NOLOCK)
	        LEFT OUTER JOIN STB_MoldTypeInfo MTI WITH(NOLOCK)
				ON MBI.MoldTypeCode = MTI.MoldTypeCode
			LEFT OUTER JOIN STB_MoldLocation ML WITH(NOLOCK)
				ON MBI.MoldLocationCode = ML.MoldLocationCode
			LEFT OUTER JOIN STB_MoldGradeType MGT WITH(NOLOCK)
				ON MBI.MoldGradeTypeCode = MGT.MoldGradeTypeCode
			LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)
				ON MBI.WorkCenterCode = WCI.WorkCenterCode
			LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK)
				ON MBI.CompanyCode = CI.CompanyCode
	WHERE
	        ((@MoldNumber = '*') OR (MBI.MoldNumber = @MoldNumber)) AND
	        ((@CompanyCode = '*') OR (MBI.CompanyCode = @CompanyCode)) AND
	        ((@WorkCenterCode = '*') OR (MBI.WorkCenterCode = @WorkCenterCode)) AND
	        ((@MoldTypeCode = '*') OR (MBI.MoldTypeCode = @MoldTypeCode)) AND
	        ((@MoldCategory1 = '*') OR (MBI.MoldCategory1 = @MoldCategory1)) AND
	        ((@MoldCategory2 = '*') OR (MBI.MoldCategory2 = @MoldCategory2)) AND
	        ((@MoldCategory3 = '*') OR (MBI.MoldCategory3 = @MoldCategory3)) 
	ORDER BY
			MBI.MoldNumber

END



