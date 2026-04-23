-- =============================================
-- Author: Jackaroe (yjyu@vina.co.kr)
-- Create date: 2019-06-21
-- Browsable : true
-- Group : 생산관리
-- Description:	원가그룹별 근무인원 배정
-- Modified:
--                 2021.08.03 근무조코드랑 명칭 문제 (채민수님)
-- EXEC [usp_CostGroupWorkerMapping_get] 'kilee', 'Korean', 'VNT_F1', 'VNT', ''
-- =============================================
CREATE PROCEDURE [dbo].[usp_CostGroupWorkerMapping_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pCostGroupCode VARCHAR(20) = NULL,
	@pCompanyCode VARCHAR(20) = NULL,
	@pJobDate DATE = NULL
AS

BEGIN

	Declare    @CostGroupCode VARCHAR(20) = @pCostGroupCode
	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
	DECLARE @JobDate DATE = CASE WHEN @pJobDate IS NULL THEN CONVERT(DATE, GETDATE()) ELSE @pJobDate END


	SELECT CGWM.CostGroupCode
		  ,CGI.CostGroupName
		  ,CGWM.WorkerCode
		  ,PWI.WorkerName
		  ,CGWM.Seq
		  ,1 AS IsAssigned
		  , DWG.WorkGroupCode

	  -- , DWG.WorkGroupName  -- 원본수정 (2021.08.03 kangs)
		 , BC3.Description AS WorkGroupName

		  ,DWG.ShiftCode
		  ,BC.Description AS ShiftName
		  ,CGWM.ApplyTime
		  ,CGWM.WorkTypeCode
		  ,BC2.Description AS WorkTypeName
		  ,CGWM.SupportCostGroupCode
		  ,CGI2.CostGroupName AS SupportCostGroupName
		  ,CGWM.CostGroupRemark
	  FROM STB_CostGroupWorkerMapping CGWM	    
	  LEFT OUTER JOIN STB_CostGroupInfo CGI	    ON CGI.CostGroupCode = CGWM.CostGroupCode
	  LEFT OUTER JOIN STB_CostGroupInfo CGI2	    ON CGI2.CostGroupCode = CGWM.SupportCostGroupCode
	  LEFT OUTER JOIN STB_ProdWorkerInfo PWI	    ON PWI.WorkerCode = CGWM.WorkerCode
	  LEFT OUTER JOIN STB_DayWorkGroup DWG	    ON JobDate = CONVERT(CHAR(10), GETDATE(), 121)	   AND DWG.WorkerCode = CGWM.WorkerCode
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC	    ON BC.ItemCode = DWG.ShiftCode	       AND CodeGroup = 'TimeShiftCode'
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC2	    ON BC2.ItemCode = CGWM.WorkTypeCode	   AND BC2.CodeGroup = 'WorkTypeCode'
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC3	    ON BC3.ItemCode = DWG.WorkGroupCode		   AND BC3.codeGroup =  'WorkGroupCode'      --2021.08.03 추가 (Kangs)

	 WHERE CGWM.CostGroupCode = @CostGroupCode
	   AND (@CompanyCode = '*' OR CGI.CompanyCode = @CompanyCode)
END