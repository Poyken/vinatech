-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 시스템관리
-- Browsable : true
-- Create date : 
-- Description : 
-- Modified :
-- 실행 :           EXEC  usp_EAWorkInfo_get '','','2019-12-01','2019-12-31'
-- =============================================


CREATE PROCEDURE [dbo].[usp_EAWorkInfo_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pFromDate DATETIME,
	@pToDate DATETIME,
	@pProcessingWorkerCode VARCHAR(20) = NULL
AS

BEGIN
	Declare @FromDate DATETIME = CONVERT(CHAR(10), @pFromDate, 121) + ' 00:00:00'
	       ,@ToDate DATETIME = CONVERT(CHAR(10), @pToDate, 121) + ' 23:59:59'
		   ,@ProcessingWorkerCode VARCHAR(20) = CASE WHEN ISNULL(@pProcessingWorkerCode,'') = '' THEN '*' ELSE @pProcessingWorkerCode          END

	SELECT EWI.EAWorkNo
		  ,EWI.RequestContent
		  ,EWI.RequestDeptCode
		  ,BC.Description AS RequestDeptName
		  ,EWI.RequestWorkerCode
		  ,PWI.EmployeeName AS RequestWorkerName
		  ,EWI.RequestDateTime
		  ,EWI.ProcessingWorkerCode
		  --,PWI2.EmployeeName AS ProcessingWorkerName

		  , CASE WHEN PWI2.EmployeeName IS NULL AND EWI.ProcessingWorkerCode = '4170609' THEN   'Mr.Giang'				   
		           ELSE  PWI2.EmployeeName END   AS ProcessingWorkerName
		  ,EWI.DueDate
		  ,EWI.FinishDateTime
		  ,EWI.IsFinish
		  ,EWI.Remark
		  ,EWI.CreateDateTime
		  ,EWI.CreateUserID
		  ,EWI.ChangeDateTime
		  ,EWI.ChangeUserID
		  ,EWI.ProcessingContent
		  ,EWI.RequestMenuPath
	  FROM STB_EAWorkInfo EWI
			  LEFT OUTER JOIN SmartFactoryIncubator.dbo.VW_EmployeeInfo PWI	    ON EWI.RequestWorkerCode = PWI.EmployeeNo
			  LEFT OUTER JOIN SmartFactoryIncubator.dbo.VW_EmployeeInfo PWI2	    ON EWI.ProcessingWorkerCode = PWI2.EmployeeNo
			  LEFT OUTER JOIN SmartFrameWork.dbo.STB_BaseCode BC	                ON EWI.RequestDeptCode = BC.ItemCode            	   AND BC.CodeGroup = 'RequestDept'
	 WHERE 1=1
	     AND RequestDateTime BETWEEN @FromDate AND @ToDate
		 AND (@ProcessingWorkerCode = '*' OR EWI.ProcessingWorkerCode = @ProcessingWorkerCode)
	 ORDER BY EWI.EAWorkNo
END