
-- =============================================
-- Author:		<손재휘>
-- Create date: <2018-03-26>
-- Description:	<근태처리>
-- =============================================
Create PROCEDURE [dbo].[workedTime_20220322]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- 휴일 체크 : 테이블(생산CALENDAR), 근무구분  1: 평일 , 3: 법정휴무, 4: 토요일, 9: 일요일
	-- 3교대 체크
	--table : 근무조 
	UPDATE C
	SET C.교대구분 ='3'
	FROM 일일근태자료 C
	JOIN 생산CALENDAR_3조2교대 B ON C.사원번호 = B.사원번호 AND C.일자 = B.일자
 	WHERE C.일자 BETWEEN CONVERT(CHAR(7), DATEADD(month, -1, GETDATE()), 121) + '-01' AND CONVERT(CHAR(10), GETDATE(), 121)
	  AND ( B.근무조 ='A' OR B.근무조 ='B' OR B.근무조 ='C' )
	
	-- 3조 2교대 
	UPDATE C 
	SET C.연장 = B.연장,C.야간 = B.야간,C.특근 = B.특근,C.특근연장 = B.특근연장, C.비고 = B.비고,C.입력자 = '18040101', C.수정일시 = GETDATE(), C.시간입력 =1
	FROM 일일근태자료 C
	JOIN 
	(
		SELECT A.일자,A.출근일자,A.퇴근일자,A.사원번호,A.출근시,A.출근분,A.퇴근시,A.퇴근분,A.교대구분,B.연장,B.특근,B.특근연장,B.야간,A.휴무,A.주야,B.비고
		FROM (
			SELECT A.일자, A.출근일자, A.퇴근일자 ,A.사원번호,A.출근시,A.출근분,A.퇴근시,A.퇴근분,A.교대구분,A.연장,A.특근,A.특근연장,A.야간, CASE WHEN CONVERT(varchar,출근일자,8) BETWEEN '08:00:00' AND '16:00:00' THEN 1 ELSE 2 END 주야
		  , CASE WHEN 근무구분 ='휴' OR (SELECT TOP 1근무구분 FROM 생산CALENDAR WHERE 근무일자 = A.일자) = '3' THEN 1 ELSE 0 END 휴무
			FROM 일일근태자료 A
			JOIN 생산CALENDAR_3조2교대 B ON A.일자 = B.일자 AND A.사원번호 =B.사원번호
			JOIN 생산CALENDAR_3조2교대_REF C ON B.REF_NUM = C.ID AND B.근무조 = C.근무조 
		) A
		LEFT JOIN 근무시간REF B ON  A.출근시 = B.출근시 AND A.출근분 = B.출근분 AND A.퇴근시 = B.퇴근시 AND A.퇴근분 = B.퇴근분 AND A.주야 =B.주야 AND B.휴무 = A.휴무
		WHERE B.출근시 IS NOT NULL 
		  --AND (A.연장 IS NULL OR A.연장 = 0)
		  AND A.교대구분 = '3'

	) B ON C.일자 =B.일자 AND C.출근일자 = B.출근일자 AND C.퇴근일자 = B.퇴근일자 AND C.사원번호 = B.사원번호 
	   AND C.일자 BETWEEN CONVERT(CHAR(7), DATEADD(month, -1, GETDATE()), 121) + '-01' AND CONVERT(CHAR(10), GETDATE(), 121)
	WHERE C.사고내용 ='01'
	  AND C.시간입력 = 0


	--정상적 처리 업데이트 --
	UPDATE C 
	SET C.연장 = B.연장,C.야간 = B.야간,C.특근 = B.특근,C.특근연장 = B.특근연장, C.비고 = B.비고,C.입력자 = '18040101', C.수정일시 = GETDATE(), C.시간입력 =1
		FROM 일일근태자료 C
	JOIN 
	(
		SELECT A.일자,A.출근일자,A.퇴근일자,A.사원번호,B.출근시,B.출근분,B.퇴근시,B.퇴근분,A.교대구분,B.연장,B.특근,B.특근연장,B.야간,B.비고
		FROM (
			SELECT A.일자, A.출근일자, A.퇴근일자 ,A.사원번호,A.출근시,A.출근분,A.퇴근시,A.퇴근분,A.교대구분,A.연장, CASE WHEN 근무구분 = '1' THEN 0 ELSE 1 END AS 휴무
			FROM 일일근태자료 A
			JOIN 생산CALENDAR C ON A.일자 = C.근무일자
		) A
		LEFT JOIN 근무시간REF B ON  A.출근시 = B.출근시 AND A.출근분 = B.출근분 AND A.퇴근시 = B.퇴근시 AND A.퇴근분 = B.퇴근분 AND A.교대구분 =B.주야 AND B.휴무 = A.휴무
		WHERE B.출근시 IS NOT NULL AND A.교대구분 <> '3'
	) B ON C.일자 =B.일자 AND C.출근일자 = B.출근일자 AND C.퇴근일자 = B.퇴근일자 AND C.사원번호 = B.사원번호 
	   AND C.일자 BETWEEN CONVERT(CHAR(7), DATEADD(month, -1, GETDATE()), 121) + '-01' AND CONVERT(CHAR(10), GETDATE(), 121)
	WHERE C.사고내용 ='01'
	  AND C.시간입력 = 0

	--예외 사람 처리 필요 
	UPDATE C
	SET C.연장 = '0',C.야간 = '0',C.특근 = '0', C.특근연장 = '0', C.비고 = '수정필요', C.입력자 = '18040101', C.수정일시 = GETDATE() 
	FROM 일일근태자료 C
	WHERE 연장 IS NULL 
	  AND C.일자 BETWEEN CONVERT(CHAR(7), DATEADD(month, -1, GETDATE()), 121) + '-01' AND CONVERT(CHAR(10), GETDATE(), 121)
	  AND C.사고내용 ='01'
	  AND C.시간입력 = 0



	--요일 추가(월 집계시 필요) 
	UPDATE C
	SET C.요일 =''
	FROM 일일근태자료 C
 	WHERE C.일자 BETWEEN CONVERT(CHAR(7), DATEADD(month, -1, GETDATE()), 121) + '-01' AND CONVERT(CHAR(10), GETDATE(), 121)
	  AND 요일 IS NULL  AND C.사고내용 ='01'
	  AND C.시간입력 = 0


	-- 3조 2교대 근무 구분 문제 
	INSERT INTO 일일근태자료
	SELECT A.일자,A.사원번호,ISNULL((SELECT TOP 1 SCD FROM erpdb.dbo.empref WHERE SABUN = A.사원번호),'9000') 부서코드,'3' 교대구분,A.일자 '출근일자','' 출근시,'' 출근분
	,NULL '외출시', NULL '외출분', NULL '귀사시', NULL '귀사분', A.일자 '퇴근일자', '' 퇴근시, '' 퇴근분,NULL '임시'
	, 0 '연장', 0 '야간' ,NULL '심야', 0 '특근', 0 '특근연장', NULL '무급휴일', 0 '지각', 0 '조퇴' , NULL '외출', NULL '구분', '' as '요일', '02' '사고내용', '3조2교대(' + B.근무조+'조)' as'비고','18040101' '입력자',NULL ' 수정자',GETDATE() '입력일시' ,NULL '수정일시',  '1' '시간입력'
	FROM 생산CALENDAR_3조2교대 A
	JOIN 생산CALENDAR_3조2교대_REF B ON A.REF_NUM = B.ID AND A.근무조 = B.근무조
	JOIN 생산CALENDAR C ON A.일자 = C.근무일자
	JOIN 
	(
	SELECT A.일자,A.사원번호 
	FROM (
		SELECT 일자,사원번호 
		FROM 생산CALENDAR_3조2교대 A
		JOIN 생산CALENDAR_3조2교대_REF B ON A.REF_NUM = B.ID AND A.근무조 = B.근무조
		JOIN 생산CALENDAR C ON A.일자 = C.근무일자
		WHERE B.근무구분 ='휴' AND C.근무구분 ='1'
	) A
	LEFT JOIN 
	일일근태자료 B ON A.일자 = B.일자 AND A.사원번호 = B.사원번호 
	WHERE B.일자 IS NULL
	) D ON A.일자 = D.일자 AND A.사원번호 = D.사원번호
	WHERE B.근무구분 ='휴' AND C.근무구분 ='1'
END