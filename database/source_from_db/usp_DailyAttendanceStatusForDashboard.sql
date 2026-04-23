CREATE PROC [dbo].[usp_DailyAttendanceStatusForDashboard]
	@pCompanyCode VARCHAR(20) = NULL,
    @pWorkCenterCode VARCHAR(20) = NULL,
	@pJobStartDate DATE = NULL,
	@pJobEndDate DATE = NULL
AS
BEGIN
	Declare @JobStartDate DATE = CASE WHEN @pJobStartDate IS NULL THEN CONVERT(DATE, GETDATE()) ELSE @pJobStartDate END
	       ,@JobEndDate DATE = CASE WHEN @pJobEndDate IS NULL THEN CONVERT(DATE, GETDATE()) ELSE @pJobEndDate END

	SELECT CGWM.WorkerCode AS 사번
		  ,PWI.WorkerName AS 성명
		  --,D.AMT AS 기준시급
		  ,CGI.CostGroupName AS 라인구분
		  ,DWG.WorkGroupName AS 근무조
		  ,CASE WHEN DWG.ShiftCode = 1 THEN '주' 
		        WHEN DWG.ShiftCode = 2 THEN '야' 
				WHEN DWG.ShiftCode = 3 THEN '휴' 
				ELSE NULL END AS 근무구분
		  ,b.일자 AS 기준일
		  ,CONVERT(DATE, b.출근일자) AS 출근일자
		  ,b.출근시 + ' : ' + b.출근분 AS 출근시간
		  ,CONVERT(DATE, b.퇴근일자) AS 퇴근일자
		  ,b.퇴근시 + ' : ' + b.퇴근분 AS 퇴근시간
		  ,DATENAME(dw, b.일자) AS 요일
		  ,C.NAME AS 이상내용
		  ,ISNULL(b.지각, 0) AS 지각
		  ,ISNULL(b.조퇴 ,0) AS 조퇴
		  ,ISNULL(b.연장 ,0) AS 연장
		  ,ISNULL(b.야간 ,0) AS 야간
		  ,ISNULL(b.특근 ,0) AS 특근
		  ,ISNULL(b.특근연장 ,0) AS 특근연장
		  ,CASE WHEN b.사고내용 IN ('03', '05', '06') THEN 0 ELSE 8 END AS 정상
		  /*
		  ,D.AMT * CASE WHEN b.사고내용 IN ('03', '05', '06') THEN 0 ELSE 8 END AS 금액_정상
		  ,D.AMT * ISNULL(b.지각 ,0) AS 금액_지각
		  ,D.AMT * ISNULL(b.조퇴 ,0) AS 금액_조퇴
		  ,D.AMT * ISNULL(b.연장 ,0) * 1.5 AS 금액_연장
		  ,D.AMT * ISNULL(b.야간 ,0) * 0.5 AS 금액_야간
		  ,D.AMT * ISNULL(b.특근 ,0) * 1.5 AS 금액_특근
		  ,D.AMT * ISNULL(b.특근연장 ,0) * 2 AS 금액_특근연장
		  ,D.AMT * (CASE WHEN b.사고내용 IN ('03', '05', '06') THEN 0 ELSE 8 END 
		                  + (ISNULL(b.연장 ,0) * 1.5) + (ISNULL(b.야간 ,0) * 0.5) 
						  + (ISNULL(b.특근 ,0) * 1.5) + (ISNULL(b.특근연장 ,0) * 2) 
						  - ISNULL(b.지각 ,0) - ISNULL(b.조퇴 ,0)) AS 금액_총액
		  */
	  FROM STB_CostGroupInfo CGI
	 INNER JOIN STB_CostGroupWorkerMapping CGWM
	    ON CGI.CostGroupCode = CGWM.CostGroupCode
	  LEFT OUTER JOIN STB_ProdWorkerInfo PWI
	    ON CGWM.WorkerCode = PWI.WorkerCode
	  LEFT OUTER JOIN erpsvr.erpdb.dbo.일일근태자료 b
		ON b.일자 BETWEEN @JobStartDate AND @JobEndDate
	   AND CGWM.WorkerCode = b.사원번호
	  LEFT OUTER JOIN STB_DayWorkGroup DWG
	    ON DWG.CompanyCode = CGI.CompanyCode
	   AND DWG.WorkCenterCode = CGI.WorkCenterCode
	   AND DWG.JobDate = b.일자
	   AND DWG.WorkerCode = CGWM.WorkerCode
	  LEFT OUTER JOIN erpsvr.erpdb.dbo.nameref c
	    ON c.nmgbn = '사고내용'
	   AND C.NMCD = B.사고내용
	  LEFT OUTER JOIN ERPSVR.ERPDB.DBO.EMPAMT D
	    ON DWG.WorkerCode = D.EMPCD
	   AND D.PSICD = '01'
	 WHERE b.일자 BETWEEN @JobStartDate AND @JobEndDate
	 ORDER BY CGI.CostGroupCode, PWI.WorkerName, b.일자
END