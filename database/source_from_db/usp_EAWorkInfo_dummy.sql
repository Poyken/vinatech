-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 시스템관리
-- Browsable : true
-- Create date : 
-- Description : 
-- Modified :
-- =============================================

CREATE PROCEDURE [dbo].[usp_EAWorkInfo_dummy]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pFromDate DATETIME = NULL,
	@pToDate DATETIME = NULL,
	@pProcessingWorkerCode VARCHAR(20) = NULL
AS

BEGIN
	Declare @EAWorkNo VARCHAR(20)
	       ,@RequestWorkerName NVARCHAR(20)

	SELECT @RequestWorkerName = UserName FROM SmartFramework.dbo.STB_UserInfo WHERE UserID = @pProcessUserID

	EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_EAWorkInfo',@EAWorkNo OUTPUT

	SELECT @EAWorkNo AS EAWorkNo
		  ,'' AS RequestContent
		  ,'' AS RequestDeptCode
		  ,'' AS RequestDeptName
		  ,@pProcessUserID AS RequestWorkerCode
		  ,@RequestWorkerName AS RequestWorkerName
		  ,GETDATE() AS RequestDateTime
		  ,'' AS RequestMenuPath
END