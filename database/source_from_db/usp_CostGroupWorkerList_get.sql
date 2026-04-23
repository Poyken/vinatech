-- =============================================
-- Author: Jackaroe (yjyu@vina.co.kr)
-- Create date: 2020-01-02
-- Browsable : true
-- Group : 생산관리
-- Description:	원가그룹 일괄조회
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_CostGroupWorkerList_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pCostGroupCode VARCHAR(20) = NULL,
	@pCompanyCode VARCHAR(20) = NULL,
	@pBaseDate DATE = NULL
AS
BEGIN
	Declare @CostGroupCode VARCHAR(20) = CASE WHEN ISNULL(@pCostGroupCode, '') = '' THEN '*' ELSE @pCostGroupCode END
		   ,@CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode, '') = '' THEN '*' ELSE @pCompanyCode END
		   ,@BaseDate DATE = CASE WHEN @pBaseDate IS NULL THEN CONVERT(DATE, GETDATE()) ELSE CONVERT(VARCHAR(10), @pBaseDate, 121) END

	SELECT CGWM.WorkerCode
		  ,PWI.WorkerName
		  ,DWG.WorkGroupCode
		  ,DWG.WorkGroupName
		  ,DWG.ShiftCode
		  ,CASE WHEN DWG.ShiftCode = '1' THEN '주간'
				WHEN DWG.ShiftCode = '2' THEN '야간'
				WHEN DWG.ShiftCode = '3' THEN '휴무'
				ELSE NULL END AS ShiftName
		  ,CGWM.CostGroupCode
		  ,CGI.CostGroupName
		  ,CGI.CompanyCode
		  ,CI.CompanyName
		  ,CGI.WorkCenterCode
		  ,WCI.WorkCenterName
		  ,CGI.CostGroupName
		  ,CGI.IsUsed
	  FROM STB_CostGroupWorkerMapping CGWM
	  LEFT OUTER JOIN STB_CostGroupInfo CGI
		ON CGWM.CostGroupCode = CGI.CostGroupCode
	  LEFT OUTER JOIN STB_ProdWorkerInfo PWI 
		ON CGWM.WorkerCode = PWI.WorkerCode
	  LEFT OUTER JOIN STB_DayWorkGroup DWG	    
		ON PWI.WorkerCode = DWG.WorkerCode	   
	   AND DWG.JobDate = @BaseDate
	  LEFT OUTER JOIN STB_CompanyInfo CI
		ON CI.CompanyCode = CGI.CompanyCode
	  LEFT OUTER JOIN STB_WorkCenterInfo WCI
		ON WCI.WorkCenterCode = CGI.WorkCenterCode
	 WHERE (@CostGroupCode = '*' OR CGWM.CostGroupCode = @CostGroupCode)
	   AND (@CompanyCode = '*' OR CGI.CompanyCode = @CompanyCode)
	   AND (@CompanyCode = '*' OR DWG.WorkGroupCode IS NOT NULL)
END