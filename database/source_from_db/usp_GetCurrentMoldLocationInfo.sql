-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-05-30
-- Browsable : true
-- Group : 금형관리
-- Description: 금형현재위치정보 조회
-- Modified:
-- =============================================
 CREATE PROCEDURE [dbo].[usp_GetCurrentMoldLocationInfo]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,
	@pCompanyName NVARCHAR(50) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
	@pWorkCenterName NVARCHAR(50) = NULL,
	@pMoldTypeCode VARCHAR(20) = NULL,
	@pMoldTypeName NVARCHAR(50) = NULL,	
	@pMoldCategory1 VARCHAR(100) = NULL,
	@pMoldCategory2 VARCHAR(100) = NULL,
	@pMoldCategory3 VARCHAR(100) = NULL	
WITH RECOMPILE
AS
BEGIN
	SET NOCOUNT ON;
	
	 
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
			MBI.WorkCenterCode,
			WCI.WorkCenterName,
			WCI.WorkCenterNameL,
			
			
			MBI.MoldTypeCode,
			MTI.MoldTypeName,
			
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
			MBI.RFTagID,
			MBI.CheckTerm1,
			MBI.CheckTerm2,
			MBI.CheckTerm3,
			MBI.MoldGradeTypeCode,
			MBI.CheckSheetType1,
			MBI.CheckSheetType2,
			MBI.CheckSheetType3,
			MBI.CheckSheetType4,
			MBI.RFTagID,
			MBI.CreateDateTime,
			MBI.CreateUserID,
			MBI.ChangeDateTime,
			MBI.ChangeUserID
			
	FROM
			STB_MoldBasicInfo MBI WITH(NOLOCK)
			LEFT OUTER JOIN STB_MoldTypeInfo MTI WITH(NOLOCK)
					ON (MTI.MoldTypeCode = MBI.MoldTypeCode)
			LEFT OUTER JOIN STB_MoldLocation ML WITH(NOLOCK)
					ON (ML.MoldLocationCode = MBI.MoldLocationCode)
			LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)
					ON (WCI.WorkCenterCode = MBI.WorkCenterCode)
			LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK)
					ON (CI.CompanyCode = MBI.CompanyCode)
						
	WHERE
			((@CompanyCode = '*') OR (CI.CompanyCode = @CompanyCode))
			AND ((@WorkCenterCode = '*') OR (MBI.WorkCenterCode = @WorkCenterCode))
			AND ((@MoldTypeCode = '*') OR (MBI.MoldTypeCode = @MoldTypeCode))			
			AND ((@MoldCategory1 = '*') or (MBI.MoldCategory1 = @MoldCategory1))
			AND ((@MoldCategory2 = '*') or (MBI.MoldCategory2 = @MoldCategory2))
			AND ((@MoldCategory3 = '*') or (MBI.MoldCategory3 = @MoldCategory3))
	ORDER BY
			MBI.MoldNumber		
	
	
	
END




