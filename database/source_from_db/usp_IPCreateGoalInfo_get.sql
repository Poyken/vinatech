-- ========================================================================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2022-04-22
-- Browsable : True
-- Group : 인사관리
-- Description: IP창출목표 관리
-- ==========================================================================================
CREATE PROCEDURE [dbo].[usp_IPCreateGoalInfo_get]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pBaseYear DATE
AS
BEGIN
	Declare @BaseYear CHAR(4) = CONVERT(CHAR(4), @pBaseYear, 121)
	
	SELECT ICGI.BaseYear AS OldBaseYear
	      ,ICGI.BaseYear
	      ,ICGI.EmployeeNo AS OldEnmployeeNo
	      ,ICGI.EmployeeNo
		  ,ME.NM_KOR AS OldEmployeeName
	      ,ME.NM_KOR AS EmployeeName
          ,ICGI.IPClassCode
		  ,BC.Description AS IPClassName
          ,ICGI.TargetQty
          ,ICGI.CreateDateTime
          ,ICGI.CreateUserID
          ,ICGI.ChangeDateTime
          ,ICGI.ChangeUserID
	  FROM STB_IPCreateGoalInfo ICGI
	  LEFT OUTER JOIN NEOE.NEOE.MA_EMP ME
	    ON ME.CD_COMPANY = '1000'
	   AND ME.NO_EMP = ICGI.EmployeeNo
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC
	    ON BC.CodeGroup = 'IPClassCode'
	   AND BC.ItemCode = ICGI.IPClassCode
	 WHERE ICGI.BaseYear = @BaseYear
END