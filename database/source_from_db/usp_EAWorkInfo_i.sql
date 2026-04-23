-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 시스템관리
-- Browsable : true
-- Create date : 
-- Description : 
-- Modified :
-- =============================================


CREATE PROCEDURE usp_EAWorkInfo_i
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pEAWorkNo VARCHAR(20),
	@pRequestDeptCode VARCHAR(20),
	@pRequestWorkerCode VARCHAR(20),
	@pRequestMenuPath NVARCHAR(1000) = NULL,
	@pRequestContent NVARCHAR(MAX)
AS

BEGIN
	Declare @EAWorkNo VARCHAR(20) = @pEAWorkNo,
			@RequestDeptCode VARCHAR(20) = @pRequestDeptCode,
			@RequestWorkerCode VARCHAR(20) = @pRequestWorkerCode,
			@RequestMenuPath NVARCHAR(1000) = @pRequestMenuPath,
			@RequestContent NVARCHAR(MAX) = @pRequestContent

	-- 화면 기본 조회 시 일련번호가 발행되므로 단순 Insert 로 처리한다. 
	-- 자동 생성되는 IUD 프로시저를 이용할 경우 업데이트로 인식되기 때문에 정상적인 입력이 되지 않음.
	INSERT INTO STB_EAWorkInfo (EAWorkNo, RequestDeptCode, RequestWorkerCode, RequestMenuPath, RequestContent, RequestDateTime)
		VALUES (@EAWorkNo, @RequestDeptCode, @RequestWorkerCode, @RequestMenuPath, @RequestContent, GETDATE())
END