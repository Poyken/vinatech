-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2019-06-26
-- Browsable : true
-- Group : 생산관리
-- Description:	현장직 근태현황 조회
-- Modified:
-- =============================================
CREATE PROC usp_DailyAttendanceStatus_get
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pCompanyCode VARCHAR(20) = NULL,
    @pWorkCenterCode VARCHAR(20) = NULL,
	@pJobStartDate DATE = NULL,
	@pJobEndDate DATE = NULL
AS
BEGIN
	Declare @JobStartDate DATE = CASE WHEN @pJobStartDate IS NULL THEN CONVERT(DATE, GETDATE()) ELSE @pJobStartDate END
	       ,@JobEndDate DATE = CASE WHEN @pJobEndDate IS NULL THEN CONVERT(DATE, GETDATE()) ELSE @pJobEndDate END

	SELECT CGWM.WorkerCode
		  ,PWI.WorkerName
		  ,D.AMT AS BasicSalary
		  ,CGI.CostGroupName
		  ,DWG.WorkGroupName
		  ,b.일자 AS JobDate
		  ,CONVERT(DATE, b.출근일자) AS WorkStartDate
		  ,b.출근시 + ' : ' + b.출근분 AS WorkStartTime
		  ,CONVERT(DATE, b.퇴근일자) AS WorkEndDate
		  ,b.퇴근시 + ' : ' + b.퇴근분 AS WorkEndTime
		  ,DATENAME(dw, b.일자) AS DayOfTheWeek
		  ,C.NAME AS WorkType
		  ,ISNULL(b.지각, 0) AS Late
		  ,ISNULL(b.조퇴 ,0) AS LeaveEarly
		  ,ISNULL(b.연장 ,0) AS Extend
		  ,ISNULL(b.야간 ,0) AS Night
		  ,ISNULL(b.특근 ,0) AS SpecialWork
		  ,ISNULL(b.특근연장 ,0) AS SpecialWorkExtend
		  ,CASE WHEN b.사고내용 IN ('03', '05', '06') THEN 0 ELSE 8 END AS Normal
		  ,D.AMT * CASE WHEN b.사고내용 IN ('03', '05', '06') THEN 0 ELSE 8 END AS NormalAmt
		  ,D.AMT * ISNULL(b.지각 ,0) AS LateAmt
		  ,D.AMT * ISNULL(b.조퇴 ,0) AS LeaveEarlyAmt
		  ,D.AMT * ISNULL(b.연장 ,0) * 1.5 AS ExtendAmt
		  ,D.AMT * ISNULL(b.야간 ,0) * 0.5 AS NightAmt
		  ,D.AMT * ISNULL(b.특근 ,0) * 1.5 AS SpecialWorkAmt
		  ,D.AMT * ISNULL(b.특근연장 ,0) * 2 AS SpecialWorkExtendAmt
		  ,D.AMT * (CASE WHEN b.사고내용 IN ('03', '05', '06') THEN 0 ELSE 8 END 
		                  + (ISNULL(b.연장 ,0) * 1.5) + (ISNULL(b.야간 ,0) * 0.5) 
						  + (ISNULL(b.특근 ,0) * 1.5) + (ISNULL(b.특근연장 ,0) * 2) 
						  - ISNULL(b.지각 ,0) - ISNULL(b.조퇴 ,0)) AS TotalAmt
	  FROM STB_CostGroupInfo CGI
	 INNER JOIN STB_CostGroupWorkerMapping CGWM
	    ON CGI.CostGroupCode = CGWM.CostGroupCode
	  LEFT OUTER JOIN STB_DayWorkGroup DWG
	    ON DWG.CompanyCode = CGI.CompanyCode
	   AND DWG.WorkCenterCode = CGI.WorkCenterCode
	   AND DWG.JobDate = CONVERT(DATE, GETDATE())
	   AND DWG.WorkerCode = CGWM.WorkerCode
	  LEFT OUTER JOIN STB_ProdWorkerInfo PWI
	    ON CGWM.WorkerCode = PWI.WorkerCode
	  LEFT OUTER JOIN erpsvr.erpdb.dbo.일일근태자료 b
		ON b.일자 BETWEEN @JobStartDate AND @JobEndDate
	   AND CGWM.WorkerCode = b.사원번호
	  LEFT OUTER JOIN erpsvr.erpdb.dbo.nameref c
	    ON c.nmgbn = '사고내용'
	   AND C.NMCD = B.사고내용
	  LEFT OUTER JOIN ERPSVR.ERPDB.DBO.EMPAMT D
	    ON DWG.WorkerCode = D.EMPCD
	   AND D.PSICD = '01'
	 WHERE b.일자 BETWEEN @JobStartDate AND @JobEndDate
	 ORDER BY CGI.CostGroupCode, PWI.WorkerName, b.일자
END