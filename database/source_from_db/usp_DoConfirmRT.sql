

-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Group : 신뢰성관리
-- Browsable : true
-- Create date: 2019-12-03
-- Description: 신뢰성의뢰를 접수합니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoConfirmRT]
	@pProcessUserID VARCHAR(20),
	@pRTSampleNo VARCHAR(20) = NULL,
	@pTestClassCode VARCHAR(10) = NULL,
	@pTestItemCode VARCHAR(10) = NULL,
	@pVoltSpec VARCHAR(10) = NULL,
	@pFaradSpec VARCHAR(10) = NULL
AS
BEGIN
	Declare @RTSampleNo VARCHAR(20) = @pRTSampleNo
	       ,@TestClassCode VARCHAR(10) = @pTestClassCode
	       ,@TestItemCode VARCHAR(10) = @pTestItemCode
	       ,@VoltSpec VARCHAR(10) = REPLACE(@pVoltSpec, '.', 'R')
	       ,@FaradSpec VARCHAR(10) = @pFaradSpec
		   ,@RTReceptionNo VARCHAR(20)

	-- 접수번호 채번
	exec usp_GetSerialNoForRT @RTSampleNo, @TestClassCode, @TestItemCode, @VoltSpec, @FaradSpec, @RTReceptionNo OUTPUT

	-- 관리 데이터 추가
	INSERT INTO STB_ReliabilityTestManagementInfo (
		RTSampleNo
       ,RTReceptionNo
       ,RTStatusCode
       ,RTReceptionDate
       ,CreateDateTime
       ,CreateUserID
	) VALUES (
		@RTSampleNo
	   ,@RTReceptionNo
	   ,'01'
	   ,GETDATE()
	   ,GETDATE()
	   ,@pProcessUserID
	)
END