CREATE PROC [dbo].[usp_CostGroupWorkerMappingHist_interface]
	@pJobDate DATE = NULL
AS
BEGIN
	IF @pJobDate IS NULL BEGIN
		SET @pJobDate = GETDATE()
	END
	-- 지정일자 데이터 삭제
	DELETE FROM STB_CostGroupWorkerMappingHist
	WHERE JobDate = @pJobDate

	DELETE FROM STB_CostGroupWorkerMapping
	WHERE CostGroupCode = 'C-99'

	-- 지정일자 데이터 입력
	INSERT INTO STB_CostGroupWorkerMappingHist (JobDate, CostGroupCode, CostGroupSeq, WorkerCode, IsAssigned
											  , CreateDateTime, CreateUserID, ChangeDateTime, ChangeUserID, JobStartDateTime
											  , SupportCostGroupCode, ApplyTime, WorkTypeCode, CostGroupRemark)
	SELECT Convert(Date, @pJobDate, 121), CostGroupCode, Seq, WorkerCode, IsAssigned
		  ,CONVERT(VARCHAR(10), @pJobDate, 121) + ' 08:30:00', 'eai', ChangeDateTime, ChangeUserID, CONVERT(VARCHAR(10), @pJobDate, 121) + ' 08:30:00'
		  ,SupportCostGroupCode, ApplyTime, WorkTypeCode, CostGroupRemark
	  FROM STB_CostGroupWorkerMapping
	 WHERE CostGroupCode <> 'C-99'

	-- @pJobDate가 GETDATE()이면 정기적인 인터페이스이므로 전일자 데이터 중 작업 종료일시가 없는 데이터는 08:30으로 갈음하여 처리한다.
	IF CONVERT(CHAR(10), @pJobDate, 121) = CONVERT(CHAR(10), GETDATE(), 121) BEGIN
		UPDATE STB_CostGroupWorkerMappingHist
		   SET JobEndDateTime = CONVERT(VARCHAR(10), GETDATE(), 121) + ' 08:30:00'
		 WHERE JobDate = CONVERT(DATE, DATEADD(day, -1, GETDATE()))
		   AND JobEndDateTime IS NULL
	END

	-- 최근 한달 사이 근태 이력에 존재하는 사번이 원가그룹에 매핑되지 않았으면, C-99로 일괄 매핑한다.
	INSERT INTO STB_CostGroupWorkerMapping (CostGroupCode, WorkerCode, IsAssigned, CreateDateTime, CreateUserID
                                       ,Seq, SupportCostGroupCode, ApplyTime, WorkTypeCode)
		SELECT 'C-99', 사원번호, 1, GETDATE(), 'eai'
			  ,1, NULL, NULL, NULL
		  FROM erpdb.dbo.일일근태자료
		 WHERE 일자 BETWEEN DATEADD(month, -1, GETDATE()) AND GETDATE()
		   AND 사원번호 NOT IN (SELECT WorkerCode
								  FROM STB_CostGroupWorkerMapping)
		 GROUP BY 사원번호
END