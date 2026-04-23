-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2021-07-08
-- Browsable : true
-- Group : 생산관리
-- Description:	라인 비가동 정보를 기록합니다.
-- Modified:
-- =============================================
CREATE PROCEDURE usp_LineNonOperationHist_get
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pCompanyCode VARCHAR(20) = NULL,
    @pWorkCenterCode VARCHAR(20) = NULL,
	@pLineCode VARCHAR(20) = NULL

AS
BEGIN
      DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
      DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END
	  DECLARE @LineCode VARCHAR(20) = CASE WHEN ISNULL(@pLineCode,'') = '' THEN '*' ELSE @pLineCode END

	  SELECT LNOH.LineNonOperationHistNo
            ,LNOH.CompanyCode
			,CI.CompanyName
            ,LNOH.WorkCenterCode
			,WCI.WorkCenterName
            ,LNOH.LineCode
			,LI.LineName
            ,LNOH.LineStopDateTime
            ,LNOH.LineRestartDateTime
            ,LNOH.LineStopRemark
            ,LNOH.LineRestartRemark
            ,LNOH.CreateDateTime
            ,LNOH.CreateUserID
            ,LNOH.ChangeDateTime
            ,LNOH.ChangeUserID
	    FROM STB_LineNonOperationHist LNOH
		LEFT OUTER JOIN STB_CompanyInfo CI
		  ON CI.CompanyCode = LNOH.CompanyCode
		LEFT OUTER JOIN STB_WorkCenterInfo WCI
		  ON WCI.WorkCenterCode = LNOH.WorkCenterCode
		LEFT OUTER JOIN STB_LineInfo LI
		  ON LI.LineCode = LNOH.LineCode
	   WHERE (@CompanyCode = '*' OR LNOH.CompanyCode = @CompanyCode)
	     AND (@WorkCenterCode = '*' OR LNOH.WorkCenterCode = @WorkCenterCode)
		 AND (@LineCode = '*' OR LNOH.LineCode = @LineCode)

END