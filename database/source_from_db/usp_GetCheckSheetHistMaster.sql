-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-06-10
-- Browsable : true
-- Group : 금형관리
-- Description:	금형점검이력마스터 조회
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetCheckSheetHistMaster]
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
    DECLARE @FromDate DATE = CASE WHEN ISNULL(@pFromDate,'') = '' THEN GETDATE() ELSE @pFromDate END
    DECLARE @ToDate DATE = CASE WHEN ISNULL(@pToDate,'') = '' THEN GETDATE() ELSE @pToDate END
    
   
    
    SELECT
				CASE WHEN ISNULL(CIDH.IsFinished,0) = 0 THEN CONVERT(BIT,0)
				ELSE CONVERT(BIT,1) END AS IsFinished,
				CIDH.CommInspDocNo AS OldCommInspDocNo,
				CIDH.CommInspDocNo,
				CIDH.CompanyCode,
				CI.CompanyName,
				CI.CompanyNameL,
				CIDH.WorkCenterCode,
				WCI.WorkCenterName,
				WCI.WorkCenterNameL,
				CIDH.CommInspTypeCode,
				CITI.CommInspTypeName,
				CITI.CommInspTypeDesc,
				CIDH.MoldNumber,
				MBI.MoldCategory1,
				MBI.MoldCategory2,
				MBI.MoldCategory3,
				MBI.MoldCategory4,
				MBI.RawMaterial,
				MBI.MakeDate,
				MBI.MakeVendor,
				CIDH.RefDocNo,
				CIDH.JobDate AS CheckDate,
				CIDH.InspUserID,
				CIDH.DocDesc AS RepairDesc,
				CIDH.CreateDateTime,
				CIDH.CreateUserID,
				CIDH.ChangeDateTime,
				CIDH.ChangeUserID
		FROM
				STB_CommInspDocHistory CIDH WITH(NOLOCK)
				LEFT OUTER JOIN STB_CommInspTypeInfo CITI WITH(NOLOCK)
					ON CITI.CommInspTypeCode = CIDH.CommInspTypeCode
				LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)
					ON WCI.WorkCenterCode = CIDH.WorkCenterCode
				LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK)
					ON CI.CompanyCode = CIDH.CompanyCode
				LEFT OUTER JOIN STB_MoldBasicInfo MBI WITH(NOLOCK)
					ON MBI.MoldNumber = CIDH.MoldNumber
		WHERE
				((@FromDate <= CIDH.JobDate) AND (CIDH.JobDate <= @ToDate)) AND
				((@CompanyCode = '*') OR (CIDH.CompanyCode = @CompanyCode)) AND
				((@WorkCenterCode = '*') OR (CIDH.WorkCenterCode = @WorkCenterCode)) AND
				((CIDH.CommInspTypeCode IN ('DailyCheck','RegularCheck','DieSpotCheck','OverhaulCheck')))

    
END


