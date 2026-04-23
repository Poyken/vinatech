-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Group : 신뢰성관리
-- Browsable : true
-- Create date: 2019-12-03
-- Description: 신뢰성의뢰를 접수취소합니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoCancelRT]
	@pProcessUserID VARCHAR(20),
	@pRTSampleNo VARCHAR(20) = NULL
AS
BEGIN
	Declare @RTSampleNo VARCHAR(20) = @pRTSampleNo

	-- 관리 데이터 추가
	UPDATE STB_ReliabilityTestManagementInfo
	   SET RTStatusCode = '99'
	 WHERE RTSampleNo = @RTSampleNo
END