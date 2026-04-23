-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2021-03-23
-- Browsable : true
-- Group : 신뢰성관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE dbo.usp_DoMakeNewRTSeq
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pRTNo VARCHAR(20)
AS
BEGIN
	Declare @RTNo VARCHAR(20) = @pRTNo
		   ,@NewSeq INT
		   ,@MaxSeq INT

	SELECT @MaxSeq = MAX(Seq)
	  FROM STB_RTInfo
	 WHERE RTNo = @RTNo

	SET @NewSeq = @MaxSeq + 1

	-- 차수생성
	INSERT INTO STB_RTInfo (RTNo, Seq, TestClassCode, TestItemCode, TestName
	                       ,ModelSpec, AppliedVoltage, Temperature, Humidity, RequestDeptCode
						   ,RequestWorkerCode, RequestDate, TestStartDate, MeasureDate, TestRestartDate
						   ,MeasureCycle, CumulativeTime, TestEndTime, ChamberCode, CDMachineChannel
						   ,JigNo, SampleQty, RTStatusCode, CreateDateTime, CreateUserID
						   ,ModelCode, ModelType, Volt, Farad, ProdSize, Remark)
       SELECT RTNo, @NewSeq, TestClassCode, TestItemCode, TestName
	         ,ModelSpec, AppliedVoltage, Temperature, Humidity, RequestDeptCode
			 ,RequestWorkerCode, RequestDate, TestStartDate, MeasureDate, TestRestartDate
			 ,MeasureCycle, CumulativeTime + MeasureCycle, TestEndTime, ChamberCode, CDMachineChannel
			 ,JigNo, SampleQty, RTStatusCode, CreateDateTime, CreateUserID
			 ,ModelCode, ModelType, Volt, Farad, ProdSize, Remark
	     FROM STB_RTInfo
		WHERE RTNo = @RTNo
		  AND Seq = @MaxSeq

	-- 이전 차수 종료 처리
	UPDATE STB_RTInfo
	   SET RTStatusCode = '03'
	 WHERE RTNo = @RTNo
	   AND Seq = @MaxSeq
END