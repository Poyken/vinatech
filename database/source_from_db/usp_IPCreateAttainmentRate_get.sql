-- ========================================================================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2022-04-22
-- Browsable : True
-- Group : 인사관리
-- Description: IP창출달성율 조회
-- ==========================================================================================
CREATE PROCEDURE usp_IPCreateAttainmentRate_get
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pBaseYear DATE
AS
BEGIN
	Declare @BaseYear CHAR(4) = CONVERT(CHAR(4), @pBaseYear, 121)

	SELECT ICGI.EmployeeNo
	      ,ME.NM_KOR AS EmployeeName
		  ,MD.NM_DEPT AS DeptName
		  ,CONVERT(DATE, ME.DT_ENTER, 112) AS EntryDate
		  ,ICGI.IPClassCode
		  ,BC.Description AS IPClassName
		  ,ICGI.TargetQty
		  ,ISNULL(ICH.RegistrationQty, 0) AS RegistrationQty
		  ,CONVERT(NUMERIC(20,5), ISNULL(ICH.RegistrationQty, 0)) / CONVERT(NUMERIC(20,5), ICGI.TargetQty) * 100 AS AttainmentRate
	  FROM STB_IPCreateGoalInfo ICGI
	  LEFT OUTER JOIN NEOE.NEOE.MA_EMP ME
	    ON ME.CD_COMPANY = '1000'
	   AND ME.NO_EMP = ICGI.EmployeeNo
	  LEFT OUTER JOIN NEOE.NEOE.MA_DEPT MD
	    ON MD.CD_COMPANY = ME.CD_COMPANY
	   AND MD.CD_DEPT = ME.CD_DEPT
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC
	    ON BC.CodeGroup = 'IPClassCode'
	   AND BC.ItemCode = ICGI.IPClassCode
	  LEFT OUTER JOIN (
			SELECT CONVERT(CHAR(4), IPCreateDate, 121) AS BaseYear, EmployeeNo, IPClassCode, COUNT(*) AS RegistrationQty
			  FROM STB_IPCreateHist 
			 WHERE CONVERT(CHAR(4), IPCreateDate) = @BaseYear 
			 GROUP BY CONVERT(CHAR(4), IPCreateDate, 121), EmployeeNo, IPClassCode
	  ) ICH
	  ON ICH.EmployeeNo = ICGI.EmployeeNo
	  AND ICH.IPClassCode = ICGI.IPClassCode
	  AND ICH.BaseYear = ICGI.BaseYear

END
