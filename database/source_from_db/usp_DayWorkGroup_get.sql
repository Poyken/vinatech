-- =============================================
-- Author: Jackaroe (yjyu@vina.co.kr)
-- Create date: 2021-02-09
-- Browsable : true
-- Group : 생산관리
-- Description:	근무조정보 조회
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_DayWorkGroup_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pCompanyCode VARCHAR(20) = NULL,
    @pWorkCenterCode VARCHAR(20) = NULL,
	@pJobDate DATE = NULL

AS

BEGIN
	Declare @CompanyCode VARCHAR(20) = CASE WHEN @pCompanyCode IS NULL THEN '*' ELSE @pCompanyCode END
	       ,@WorkCenterCode VARCHAR(20) = CASE WHEN @pWorkCenterCode IS NULL THEN '*' ELSE @pWorkCenterCode END
		   ,@JobDate DATE = @pJobDate

	SELECT DWG.CompanyCode
	      ,CI.CompanyName
	      ,DWG.WorkCenterCode
		  ,WCI.WorkCenterName
		  ,DWG.JobDate
		  ,DWG.WorkerCode
		  ,PWI.WorkerName
		  ,DWG.WorkGroupCode
		  ,DWG.WorkGroupName
		  ,DWG.ShiftCode
		  ,BC.Description AS ShiftName
		  ,DWG.CompanyCode AS OldCompanyCode
	      ,DWG.WorkCenterCode AS OldWorkCenterCode
		  ,DWG.JobDate AS OldJobDate
		  ,DWG.WorkerCode AS OldWorkerCode
	  FROM STB_DayWorkGroup DWG
	  LEFT OUTER JOIN STB_CompanyInfo CI
	    ON CI.CompanyCode = DWG.CompanyCode
	  LEFT OUTER JOIN STB_WorkCenterInfo WCI
	    ON WCI.WorkCenterCode = DWG.WorkCenterCode
	  LEFT OUTER JOIN STB_ProdWorkerInfo PWI
	    ON PWI.WorkerCode = DWG.WorkerCode
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC
	    ON BC.CodeGroup = 'TimeShiftCode'
	   AND BC.ItemCode = DWG.ShiftCode
	 WHERE 1=1
	    AND (@CompanyCode = '*' OR DWG.CompanyCode = @CompanyCode)
	    AND (@WorkCenterCode = '*' OR DWG.WorkCenterCode = @WorkCenterCode)
		AND JobDate = @JobDate

END