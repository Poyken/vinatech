-- =============================================
-- Author: Jackaroe
-- Create date: 2020.01.08
-- Browsable : true
-- Group : 시스템관리
-- Description:	더존ERP의 사원이미지를 불러옵니다.
-- Modified:
-- =============================================
CREATE PROCEDURE usp_DuzonEmpPicture_get
	@pProcessUserID [varchar](20),
	@pProcessLanguage [varchar](20),
	@pWorkerCode [varchar](20) = NULL
AS
BEGIN
	Declare @WorkerCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkerCode, '') = '' THEN '*' ELSE @pWorkerCode END
	
	SELECT P.FILENAME
	      ,P.IMAGE
		  ,EI.EmployeeNo AS WorkerCode
		  ,EI.EmployeeName AS WorkerName
	  FROM DZICUBE.dbo.PICTURE P
	  LEFT OUTER JOIN SmartFactoryIncubator.dbo.VW_EmployeeInfo EI
	    ON P.DESCRIPTION = EI.EmployeeNo
	  WHERE (@WorkerCode = '*' OR P.DESCRIPTION = @WorkerCode)
	  ORDER BY EI.EmployeeNo
END