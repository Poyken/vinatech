-- Procedure: usp_BatchJobMonResult
CREATE PROC [dbo].[usp_BatchJobMonResult]
AS
BEGIN
	Declare @date DATE = DATEADD(day, -1, GETDATE()) -- 실행 시점 기준 전일자
	
	--배치잡 결과 삭제
	DELETE FROM STB_BatchJobResultInfo

	-- 전체 실행내역
	INSERT INTO STB_BatchJobResultInfo (ResultString, BatchJobResultType)
	SELECT ResultString, BatchJobResultType
	  FROM (
			SELECT '<!DOCTYPE html><html><head><meta charset="EUC-KR"><style TYPE="text/css">table {font-size: 75%;}table, td, th {border : 1px solid black; border-collapse : collapse;padding: 5px;};</style></head><body>' AS ResultString, 1 AS BatchJobResultType
			UNION ALL
			SELECT '<table border=1><tr><th>배치잡</th><th>단계</th><th>메시지</th><th>실행일자</th><th>실행결과</th></tr>', 1
			UNION ALL
			SELECT   DISTINCT 
					 '<tr><td>' + A.name + '</td>'
				   + '<td>' + B.step_name + '</td>'
				   + '<td>' + LEFT(REPLACE(B.message, '. ', '.' + CHAR(10)), 50) + '</td>'
				   + '<td>' + CONVERT(CHAR(8), B.run_date) + '</td>'
				   + '<td>' + CASE WHEN B.run_status = 0 THEN N'<font color="red">실패</font>'
						  WHEN B.run_status = 1 THEN N'성공'
						  WHEN B.run_status = 2 THEN N'<font color="red">재시도</font>'
						  WHEN B.run_status = 3 THEN N'<font color="red">취소</font>'
						  WHEN B.run_status = 4 THEN N'<font color="red">진행중</font>'
					 END  + '</td></tr>', 1
			  FROM msdb.dbo.sysjobs(NOLOCK) A
				   INNER JOIN msdb.dbo.sysjobhistory(NOLOCK) B ON A.job_id = B.job_id
			 WHERE B.step_id > 0
			   AND B.run_date = CONVERT(CHAR(8), @date, 112)
			   AND A.name NOT LIKE 'vvt%'
			UNION ALL
			SELECT '</table></body></html>', 1
		) A

	-- 오류내역
	INSERT INTO STB_BatchJobResultInfo (ResultString, BatchJobResultType)
	SELECT ResultString, BatchJobResultType
	  FROM (
			SELECT '<!DOCTYPE html><html><head><meta charset="EUC-KR"><style TYPE="text/css">table {font-size: 75%;}table, td, th {border : 1px solid black; border-collapse : collapse;padding: 5px;};</style></head><body>' AS ResultString, 2 AS BatchJobResultType
			UNION ALL
			SELECT '<table border=1><tr><th>배치잡</th><th>단계</th><th>메시지</th><th>실행일자</th><th>실행결과</th></tr>', 2
			UNION ALL
			SELECT   DISTINCT 
					 '<tr><td>' + A.name + '</td>'
				   + '<td>' + B.step_name + '</td>'
				   + '<td>' + LEFT(REPLACE(B.message, '. ', '.' + CHAR(10)), 50) + '</td>'
				   + '<td>' + CONVERT(CHAR(8), B.run_date) + '</td>'
				   + '<td>' + CASE WHEN B.run_status = 0 THEN N'<font color="red">실패</font>'
						  WHEN B.run_status = 1 THEN N'성공'
						  WHEN B.run_status = 2 THEN N'<font color="red">재시도</font>'
						  WHEN B.run_status = 3 THEN N'<font color="red">취소</font>'
						  WHEN B.run_status = 4 THEN N'<font color="red">진행중</font>'
					 END  + '</td></tr>', 2
			  FROM msdb.dbo.sysjobs(NOLOCK) A
				   INNER JOIN msdb.dbo.sysjobhistory(NOLOCK) B ON A.job_id = B.job_id
			 WHERE B.step_id > 0
			   AND B.run_status <> 1
			   AND B.run_date = CONVERT(CHAR(8), @date, 112)
			   AND A.name NOT LIKE 'vvt%'
			UNION ALL
			SELECT '</table></body></html>', 2
		) A
END
GO

