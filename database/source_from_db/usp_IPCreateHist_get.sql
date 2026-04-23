-- ========================================================================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2022-04-22
-- Browsable : True
-- Group : 인사관리
-- Description: IP창출이력 조회
-- ==========================================================================================
CREATE PROCEDURE [dbo].[usp_IPCreateHist_get]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pIPCreateDate DATE
AS
BEGIN
	Declare @IPCreateYear CHAR(4) = CONVERT(CHAR(4), Year(@pIPCreateDate), 121)

	SELECT IPCH.IPCreateHistNo
	      ,ME.NO_EMP AS EmployeeNo
	      ,ME.NM_KOR AS EmployeeName
		  ,MD.NM_DEPT AS DeptName
		  ,CONVERT(DATE, ME.DT_ENTER, 112) AS EntryDate
		  ,IPCH.IPClassCode
		  ,BC.Description AS IPClassName
		  ,IPCH.IPCreateDate
		  ,IPCH.IPTitle
		  ,IPCH.ApplicationNo
		  ,IPCH.CreateDateTime
		  ,IPCH.CreateUserID
		  ,IPCH.ChangeDateTime
		  ,IPCH.ChangeUserID
	  FROM STB_IPCreateHist IPCH
	  LEFT OUTER JOIN NEOE.NEOE.MA_EMP AS ME
	    ON IPCH.EmployeeNo = ME.NO_EMP
	   AND ME.CD_COMPANY = '1000'
	   AND IPCH.IPCreateDate BETWEEN @IPCreateYear + '-01-01' AND @IPCreateYear + '-12-31' 
	   --ANd IPCH.IPClassCode = 'IP001'
	  LEFT OUTER JOIN NEOE.NEOE.MA_DEPT MD
	    ON MD.CD_COMPANY = '1000'
	   AND MD.CD_DEPT = ME.CD_DEPT
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC
	    ON BC.CodeGroup = 'IPClassCode'
	   AND BC.ItemCode = IPCH.IPClassCode
	 WHERE MD.NM_DEPT LIKE '%개발%'
	   AND ME.CD_INCOM = '001'
	   AND ME.CD_COMPANY = '1000'
END